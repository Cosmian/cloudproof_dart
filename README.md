# Cloudproof




## Installation

```
flutter pub get cloudproof
```

## Example

To run the example, you need a Redis server configured and populated with our [Java example](https://github.com/Cosmian/cloudproof_java) (`docker compose up` then `mvn test`). Then, update `redisHost` and `redisPort` at the top of the `example/lib/main.dart` file.

## Tests

### Supported versions


| Linux        | Flutter | Dart   | Android SDK       | NDK | Glibc | LLVM     | Smartphone Virtual Device |
|--------------|---------|--------|-------------------|-----|-------|----------|---------------------------|
| Ubuntu 22.04 | 3.3.2   | 2.18.1 | Chipmunk 2021.2.1 | r22 | 2.35  | 14.0.0-1 | Pixel 5 API 30            |
| Centos 7     | 3.3.2   | 2.18.1 | Chipmunk 2021.2.1 | r22 | 2.17  | -        | -                         |


| Mac      | Flutter | Dart   | OS       | LLVM   | Xcode | Smartphone Virtual Device |
|----------|---------|--------|----------|--------|-------|---------------------------|
| Catalina | 3.3.2   | 2.18.1 | Catalina | 12.0.0 |       | iPhone 12 PRO MAX         |

To run all tests:

```
flutter test
```

Some tests require a Redis database on localhost (default port).

If you ran the Java test which populate the Redis database, you can run the hidden test that read from this database.

```
RUN_JAVA_E2E_TESTS=1 flutter test --plain-name 'Search and decrypt with preallocate Redis by Java'
```

If you share the same Redis database between Java and Dart tests, `flutter test` will cleanup the Redis database (it could take some time and timeout on the first execution). So you may want to re-run `mvn test` to populate the Redis database again.

You can run the benchmarks with:

```
dart benchmark/cloudproof_benchmark.dart
```

## Usage

### CoverCrypt

CoverCrypt allows to decrypt data previously encrypted with one of our libraries (Java, Python, Rust…).

Two classes are available: `CoverCryptDecryption` and `CoverCryptDecryptionWithCache` which is a little bit faster (omit the initialization phase during decryption). See `test/covercrypt_test.dart`.

### Findex

Findex allows to do encrypted search queries on an encrypted index. To use Findex you need a driver which is able to store and update indexes (it could be SQLite, Redis, or any other storage method). You can find in `test/findex_redis_test.dart` and `test/findex_sqlite_test.dart` two example of implementation.

To search, you need:
1. copy/paste the following lines
2. replace `TODO_ReplaceThisByTheNameOfYourClassOrTheRawFunction` by the name of your class
3. implement `fetchEntries` and `fetchChains`

```dart
  static Future<Map<Uint8List, Uint8List>> fetchEntries(
    List<Uint8List> uids,
  ) async {
    // Implement me!
  }

  static Future<Map<Uint8List, Uint8List>> fetchChains(
    List<Uint8List> uids,
  ) async {
    // Implement me!
  }

  // --------------------------------------------------
  // Copy-paste code :AutoGeneratedImplementation
  // --------------------------------------------------

  static Future<List<IndexedValue>> search(
    Uint8List keyK,
    Uint8List label,
    List<Word> words,
  ) async {
    return await Findex.search(
      keyK,
      label,
      words,
      Pointer.fromFunction(
        fetchEntriesCallback,
        errorCodeInCaseOfCallbackException,
      ),
      Pointer.fromFunction(
        fetchChainsCallback,
        errorCodeInCaseOfCallbackException,
      ),
    );
  }

  static int fetchEntriesCallback(
    Pointer<Uint8> outputPointer,
    Pointer<Uint32> outputLength,
    Pointer<Uint8> entriesUidsListPointer,
    int entriesUidsListLength,
  ) {
    return Findex.fetchWrapper(
      outputPointer,
      outputLength,
      entriesUidsListPointer,
      entriesUidsListLength,
      TODO_ReplaceThisByTheNameOfYourClassOrTheRawFunction.fetchEntries,
    );
  }

  static int fetchChainsCallback(
    Pointer<Uint8> outputPointer,
    Pointer<Uint32> outputLength,
    Pointer<Uint8> chainsUidsListPointer,
    int chainsUidsListLength,
  ) {
    return Findex.fetchWrapper(
      outputPointer,
      outputLength,
      chainsUidsListPointer,
      chainsUidsListLength,
      TODO_ReplaceThisByTheNameOfYourClassOrTheRawFunction.fetchChains,
    );
  }
```

To upsert, you need:
1. copy/paste the following lines
2. replace `TODO_ReplaceThisByTheNameOfYourClassOrTheRawFunction` by the name of your class
3. implement `fetchEntries`, `upsertEntries` and `upsertChains`

```dart
  static Future<void> upsertEntries(Map<Uint8List, Uint8List> entries) async {
    // Implement me!
  }

  static Future<void> upsertChains(Map<Uint8List, Uint8List> chains) async {
    // Implement me!
  }

  // --------------------------------------------------
  // Copy-paste code :AutoGeneratedImplementation
  // --------------------------------------------------

  static Future<void> upsert(
    MasterKeys masterKeys,
    Uint8List label,
    Map<IndexedValue, List<Word>> indexedValuesAndWords,
  ) async {
    await Findex.upsert(
      masterKeys,
      label,
      indexedValuesAndWords,
      Pointer.fromFunction(
        fetchEntriesCallback,
        errorCodeInCaseOfCallbackException,
      ),
      Pointer.fromFunction(
        upsertEntriesCallback,
        errorCodeInCaseOfCallbackException,
      ),
      Pointer.fromFunction(
        upsertChainsCallback,
        errorCodeInCaseOfCallbackException,
      ),
    );
  }

  static int fetchEntriesCallback(
    Pointer<Uint8> outputPointer,
    Pointer<Uint32> outputLength,
    Pointer<Uint8> entriesUidsListPointer,
    int entriesUidsListLength,
  ) {
    return Findex.fetchWrapper(
      outputPointer,
      outputLength,
      entriesUidsListPointer,
      entriesUidsListLength,
      TODO_ReplaceThisByTheNameOfYourClassOrTheRawFunction.fetchEntries,
    );
  }

  static int upsertEntriesCallback(
    Pointer<Uint8> entriesListPointer,
    int entriesListLength,
  ) {
    return Findex.upsertWrapper(
      entriesListPointer,
      entriesListLength,
      TODO_ReplaceThisByTheNameOfYourClassOrTheRawFunction.upsertEntries,
    );
  }

  static int upsertChainsCallback(
    Pointer<Uint8> chainsListPointer,
    int chainsListLength,
  ) {
    return Findex.upsertWrapper(
      chainsListPointer,
      chainsListLength,
      TODO_ReplaceThisByTheNameOfYourClassOrTheRawFunction.upsertChains,
    );
  }
```

Note that if you `search` and `upsert`, the two implementation can share the same callback for `fetchEntries`.

Note that the copy/paste code could be removed in a future version when Dart implements https://github.com/dart-lang/language/issues/1482.

#### ⚠️⚠️⚠️ WARNINGS ⚠️⚠️⚠️

- `fetchEntries`, `fetchChains`, `upsertEntries` and `upsertChains` can be static methods in a class or raw functions but should be static! You cannot put classic methods of an instance here.
- `fetchEntries`, `fetchChains`, `upsertEntries` and `upsertChains` cannot access the state of the program, they will run in a separate `Isolate` with no data from the main thread (for example static/global variables populated during an initialization phase of your program will not exist). If you need to access some data from the main thread, the only way we think we'll work is to save this information inside a file or a database and read it from the callback. This pattern will slow down the `search` process. If you don't need async in the callbacks (for example the `sqlite` library has sync functions, you can call `*WrapperWithoutIsolate` and keep all the process in the same thread, so you can use your global variables).

### Implementation details

- The `search` and `upsert` methods will call the Rust FFI via native bindings synchronously. If you want to not stop your main thread, please call `compute` to run the search in a different Isolate.
- The `Findex.fetchWrapper` and `Findex.upsertWrapper` will wrap your callback inside an isolate to allow you to use asynchronous callbacks.
- The `Findex.fetchWrapperWithoutIsolate` and `Findex.upsertWrapperWithoutIsolate` will wrap juste call your callback so you will not have access to `async` but your callbacks are executed inside the main isolate (so you have access to your global data)


## FFI libs notes

### Generating `.h`

The `lib/src/cover_crypt/generated_bindings.dart` is generated with `ffigen` with the config file `./ffigen_cover_crypt.yml`. There is a custom config file (instead of using the `pubspec.yml` because we may want to generate bindings for Findex in the future). Findex bindings are hand written because they are more complex and generated bindings require some casts (in particular with `Pointer<Uint8>>` from the Dart `Uint8List` type to `Pointer<Char>>`, it's working for CoverCrypt but maybe it's better to have the bindings with the `uint8` types like in Findex?).

Use cbindgen, do not forget to remove `str` type in `libcosmian_cover_crypt.h` (last two lines) for iOS to compile (type `str` unknown in C headers).

The two `.h` need to be inside the `ios/Classes` folder. Android doesn't need `.h` files.

### Building `.so`, `.a`…

#### Linux

Just copy `.so` file from the Rust projects to the `resources` folder. These `.so` are only useful to run the tests on Linux.

#### Android

Download artifacts from the Gitlab CI. You should get a `jniLibs` folder to copy to `android/src/main`.

#### iOS

If building with `cargo lipo` on Linux we only get `aarch64-apple-ios` and `x86_64-apple-ios`.

On codemagic.io:
- `aarch64-apple-ios` is failing with "ld: in /Users/builder/clone/ios/libcosmian_cover_crypt.a(cover_crypt.cover_crypt.aea4b2d2-cgu.0.rcgu.o), building for iOS Simulator, but linking in object file built for iOS, file '/Users/builder/clone/ios/libcosmian_cover_crypt.a' for architecture arm64"
- `x86_64-apple-ios` is failing with "ld: warning: ignoring file /Users/builder/clone/ios/libcosmian_cover_crypt.a, building for iOS Simulator-arm64 but attempting to link with file built for iOS Simulator-x86_64"

To make the flutter build succeed, 3 prerequisites are needed:
- declaring headers (CoverCrypt and Findex) in CloudproofPlugin.h (concat both headers)
- call artificially 1 function of each native library in SwiftCloudproofPlugin.swift
- use universal ios build: copy both .a in `cloudproof_flutter/ios`
