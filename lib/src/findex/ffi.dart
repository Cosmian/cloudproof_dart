import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';
import 'dart:io' show Directory, Platform, sleep;
import 'dart:isolate';
import 'dart:typed_data';
import 'package:cloudproof/cloudproof.dart';
import 'package:cloudproof/src/utils/leb128.dart';
import 'package:path/path.dart' as path;
import 'package:ffi/ffi.dart';
import 'package:tuple/tuple.dart';

// :Dart2.12 Replace Int32 and Uint32 to Int and UnsignedInt

typedef NativeUpsertFunc = Int32 Function(
  Pointer<Utf8>,
  Pointer<Uint8>,
  Int32,
  Pointer<Utf8>,
  Pointer<NativeFunction<FetchEntriesFfiCallback>>,
  Pointer<NativeFunction<UpsertEntriesFfiCallback>>,
  Pointer<NativeFunction<UpsertChainsFfiCallback>>,
);

typedef HUpsert = int Function(
  Pointer<Utf8>,
  Pointer<Uint8>,
  int,
  Pointer<Utf8>,
  Pointer<NativeFunction<FetchEntriesFfiCallback>>,
  Pointer<NativeFunction<UpsertEntriesFfiCallback>>,
  Pointer<NativeFunction<UpsertChainsFfiCallback>>,
);

typedef NativeSearchFunc = Int32 Function(
  Pointer<Uint8>,
  Pointer<Int32>,
  Pointer<Uint8>,
  Int32,
  Pointer<Uint8>,
  Int32,
  Pointer<Utf8>,
  Int32,
  Pointer<NativeFunction<FetchEntriesFfiCallback>>,
  Pointer<NativeFunction<FetchChainsFfiCallback>>,
);

typedef HSearch = int Function(
  Pointer<Uint8>,
  Pointer<Int32>,
  Pointer<Uint8>,
  int,
  Pointer<Uint8>,
  int,
  Pointer<Utf8>,
  int,
  Pointer<NativeFunction<FetchEntriesFfiCallback>>,
  Pointer<NativeFunction<FetchChainsFfiCallback>>,
);

typedef FetchEntriesFfiCallback = Int32 Function(
  Pointer<Uint8>,
  Pointer<Uint32>,
  Pointer<Uint8>,
  Uint32,
);

typedef FetchEntriesCallback = Future<Map<Uint8List, Uint8List>> Function(
  List<Uint8List>,
);

typedef FetchCallback = Future<Map<Uint8List, Uint8List>> Function(
  List<Uint8List>,
);

typedef FetchChainsFfiCallback = Int32 Function(
  Pointer<Uint8>,
  Pointer<Uint32>,
  Pointer<Uint8>,
  Uint32,
);
typedef FetchChainsCallback = Future<Map<Uint8List, Uint8List>> Function(
  List<Uint8List>,
);

typedef UpsertEntriesFfiCallback = Int32 Function(
  Pointer<Uint8>,
  Uint32,
);
typedef UpsertEntriesCallback = Future<void> Function(
  Map<Uint8List, Uint8List>,
);
typedef UpsertCallback = Future<void> Function(Map<Uint8List, Uint8List>);

typedef UpsertChainsFfiCallback = Int32 Function(
  Pointer<Uint8>,
  Uint32,
);
typedef UpsertChainsCallback = Future<void> Function(
  Map<Uint8List, Uint8List>,
);

const errorCodeInCaseOfCallbackException = 42;

class Ffi {
  static DynamicLibrary? _dylib;

  static DynamicLibrary get dylib {
    if (_dylib != null) {
      return _dylib as DynamicLibrary;
    }

    var libraryPath =
        path.join(Directory.current.path, 'resources', 'libcosmian_findex.so');
    if (Platform.isMacOS) {
      libraryPath = path.join(
          Directory.current.path, 'resources', 'libcosmian_findex.dylib');
    } else if (Platform.isWindows) {
      libraryPath = path.join(
          Directory.current.path, 'resources', 'libcosmian_findex.dll');
    }

    final dylib = DynamicLibrary.open(libraryPath);
    _dylib = dylib;
    return dylib;
  }

  static int fetchWrapper(
    Pointer<Uint8> outputPointer,
    Pointer<Uint32> outputLength,
    Pointer<Uint8> uidsListPointer,
    int uidsListLength,
    FetchCallback callback,
  ) {
    try {
      final donePointer = calloc<Bool>(1);

      Isolate.spawn((message) async {
        try {
          final uids = Leb128.deserializeList(
              Pointer<Uint8>.fromAddress(message.item3)
                  .asTypedList(uidsListLength));

          final values = await callback(uids);

          final output = Pointer<Uint8>.fromAddress(message.item1)
              .asTypedList(Pointer<Int32>.fromAddress(message.item2).value);

          Leb128.serializeHashMap(output, values);
        } catch (e) {
          log("Excepting in fetch isolate. $e");
        } finally {
          Pointer<Bool>.fromAddress(message.item4).value = true;
        }
      },
          Tuple4(outputPointer.address, outputLength.address,
              uidsListPointer.address, donePointer.address));

      while (!donePointer.value) {
        sleep(const Duration(milliseconds: 10));
      }

      return 0;
    } catch (e, stacktrace) {
      log("Exception during fetch wrapper $e $stacktrace");
      rethrow;
    }
  }

  static int upsertWrapper(
    Pointer<Uint8> valuesByUidsPointer,
    int valuesByUidsLength,
    UpsertCallback callback,
  ) {
    try {
      final donePointer = calloc<Bool>(1);

      Isolate.spawn((message) async {
        try {
          final valuesByUids = Leb128.deserializeHashMap(
              Pointer<Uint8>.fromAddress(message.item1)
                  .asTypedList(valuesByUidsLength));

          await callback(valuesByUids);
        } catch (e) {
          log("Excepting in upsert isolate. $e");
        } finally {
          Pointer<Bool>.fromAddress(message.item2).value = true;
        }
      }, Tuple2(valuesByUidsPointer.address, donePointer.address));

      while (!donePointer.value) {
        sleep(const Duration(milliseconds: 10));
      }

      return 0;
    } catch (e, stacktrace) {
      log("Exception during upsert wrapper $e $stacktrace");
      rethrow;
    }
  }

  static Future<void> upsert(
    MasterKeys masterKeys,
    Uint8List label,
    Map<IndexedValue, List<Word>> indexedValuesAndWords,
    Pointer<NativeFunction<FetchEntriesFfiCallback>> fetchEntries,
    Pointer<NativeFunction<UpsertEntriesFfiCallback>> upsertEntries,
    Pointer<NativeFunction<UpsertChainsFfiCallback>> upsertChains,
  ) async {
    final HUpsert hUpsert =
        dylib.lookup<NativeFunction<NativeUpsertFunc>>('h_upsert').asFunction();

    final indexedValuesAndWordsString = indexedValuesAndWords.map(
        (key, value) =>
            MapEntry(key.toBase64(), value.map((e) => e.toBase64()).toList()));

    final masterKeysJson = jsonEncode(masterKeys.toJson());
    final Pointer<Utf8> masterKeysPointer = masterKeysJson.toNativeUtf8();

    final indexedValuesAndWordsJson = jsonEncode(indexedValuesAndWordsString);
    final Pointer<Utf8> indexedValuesAndWordsPointer =
        indexedValuesAndWordsJson.toNativeUtf8();

    final result = hUpsert(
      masterKeysPointer,
      label.allocateUint8Pointer(),
      label.length,
      indexedValuesAndWordsPointer,
      fetchEntries,
      upsertEntries,
      upsertChains,
    );

    if (result != 0) {
      throw Exception("Fail to upsert");
    }
  }

  static Future<List<Uint8List>> search(
    Uint8List k,
    Uint8List label,
    List<Word> words,
    Pointer<NativeFunction<FetchEntriesFfiCallback>> fetchEntries,
    Pointer<NativeFunction<FetchChainsFfiCallback>> fetchChains,
  ) async {
    final HSearch hSearch =
        dylib.lookup<NativeFunction<NativeSearchFunc>>('h_search').asFunction();

    final wordsString = words.map((value) => value.toBase64()).toList();

    const outputLength = 131072;
    final output = calloc<Uint8>(outputLength);

    final outputLengthPointer = calloc<Int32>(1);
    outputLengthPointer.value = outputLength;

    // :Dart2.12 Switch to `.toNativeUtf8()`
    final wordsJson = jsonEncode(wordsString);
    final Pointer<Utf8> wordsPointer = wordsJson.toNativeUtf8();

    final result = hSearch(
      output,
      outputLengthPointer,
      k.allocateUint8Pointer(),
      k.length,
      label.allocateUint8Pointer(),
      label.length,
      wordsPointer,
      0,
      fetchEntries,
      fetchChains,
    );

    if (result != 0) {
      throw Exception("Fail to search ${getLastError()}");
    }

    return Leb128.deserializeList(output.asTypedList(outputLength));
  }

  static String getLastError() {
    late final getLastErrorPointer =
        dylib.lookup<NativeFunction<Int Function(Pointer<Char>, Pointer<Int>)>>(
            'get_last_error');

    final getLastError = getLastErrorPointer
        .asFunction<int Function(Pointer<Char>, Pointer<Int>)>();

    final errorPointer = calloc<Uint8>(3000);
    final errorLength = calloc<Int>(1);
    errorLength.value = 3000;

    final result = getLastError(errorPointer.cast<Char>(), errorLength);

    if (result != 0) {
      return "Fail to fetch last error…";
    } else {
      return const Utf8Decoder()
          .convert(errorPointer.asTypedList(errorLength.value));
    }
  }
}

extension Uint8ListBlobConversion on Uint8List {
  /// Allocates a pointer filled with the Uint8List data.
  Pointer<Uint8> allocateUint8Pointer() {
    final blob = calloc<Uint8>(length);
    final blobBytes = blob.asTypedList(length);
    blobBytes.setAll(0, this);
    return blob;
  }
}
