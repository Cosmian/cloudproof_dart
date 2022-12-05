// ignore_for_file: constant_identifier_names, non_constant_identifier_names

// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
import 'dart:ffi' as ffi;

/// Dart bindings to call Findex functions
class FindexNativeLibrary {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  FindexNativeLibrary(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  FindexNativeLibrary.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  /// # Safety
  /// cannot be safe since using FFI
  int h_upsert(
    ffi.Pointer<ffi.Char> master_keys_ptr,
    ffi.Pointer<ffi.Int> label_ptr,
    int label_len,
    ffi.Pointer<ffi.Char> indexed_values_and_words_ptr,
    FetchEntryTableCallback fetch_entry,
    UpdateEntryTableCallback upsert_entry,
    UpdateChainTableCallback upsert_chain,
  ) {
    return _h_upsert(
      master_keys_ptr,
      label_ptr,
      label_len,
      indexed_values_and_words_ptr,
      fetch_entry,
      upsert_entry,
      upsert_chain,
    );
  }

  late final _h_upsertPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Int>,
              ffi.Int,
              ffi.Pointer<ffi.Char>,
              FetchEntryTableCallback,
              UpdateEntryTableCallback,
              UpdateChainTableCallback)>>('h_upsert');
  late final _h_upsert = _h_upsertPtr.asFunction<
      int Function(
          ffi.Pointer<ffi.Char>,
          ffi.Pointer<ffi.Int>,
          int,
          ffi.Pointer<ffi.Char>,
          FetchEntryTableCallback,
          UpdateEntryTableCallback,
          UpdateChainTableCallback)>();

  /// Works the same as `h_upsert()` but upserts the graph of all words used in
  /// `indexed_values_and_words` too.
  ///
  /// # Safety
  /// cannot be safe since using FFI
  int h_graph_upsert(
    ffi.Pointer<ffi.Char> master_keys_ptr,
    ffi.Pointer<ffi.Int> label_ptr,
    int label_len,
    ffi.Pointer<ffi.Char> indexed_values_and_words_ptr,
    FetchEntryTableCallback fetch_entry,
    UpdateEntryTableCallback upsert_entry,
    UpdateChainTableCallback upsert_chain,
  ) {
    return _h_graph_upsert(
      master_keys_ptr,
      label_ptr,
      label_len,
      indexed_values_and_words_ptr,
      fetch_entry,
      upsert_entry,
      upsert_chain,
    );
  }

  late final _h_graph_upsertPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Int>,
              ffi.Int,
              ffi.Pointer<ffi.Char>,
              FetchEntryTableCallback,
              UpdateEntryTableCallback,
              UpdateChainTableCallback)>>('h_graph_upsert');
  late final _h_graph_upsert = _h_graph_upsertPtr.asFunction<
      int Function(
          ffi.Pointer<ffi.Char>,
          ffi.Pointer<ffi.Int>,
          int,
          ffi.Pointer<ffi.Char>,
          FetchEntryTableCallback,
          UpdateEntryTableCallback,
          UpdateChainTableCallback)>();

  /// # Safety
  /// cannot be safe since using FFI
  int h_search(
    ffi.Pointer<ffi.Char> indexed_values_ptr,
    ffi.Pointer<ffi.Int> indexed_values_len,
    ffi.Pointer<ffi.Char> key_k_ptr,
    int key_k_len,
    ffi.Pointer<ffi.Int> label_ptr,
    int label_len,
    ffi.Pointer<ffi.Char> words_ptr,
    int loop_iteration_limit,
    int max_depth,
    int progress_callback,
    FetchEntryTableCallback fetch_entry,
    FetchChainTableCallback fetch_chain,
  ) {
    return _h_search(
      indexed_values_ptr,
      indexed_values_len,
      key_k_ptr,
      key_k_len,
      label_ptr,
      label_len,
      words_ptr,
      loop_iteration_limit,
      max_depth,
      progress_callback,
      fetch_entry,
      fetch_chain,
    );
  }

  late final _h_searchPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Int>,
              ffi.Pointer<ffi.Char>,
              ffi.Int,
              ffi.Pointer<ffi.Int>,
              ffi.Int,
              ffi.Pointer<ffi.Char>,
              ffi.Int,
              ffi.Int,
              ffi.Int,
              FetchEntryTableCallback,
              FetchChainTableCallback)>>('h_search');
  late final _h_search = _h_searchPtr.asFunction<
      int Function(
          ffi.Pointer<ffi.Char>,
          ffi.Pointer<ffi.Int>,
          ffi.Pointer<ffi.Char>,
          int,
          ffi.Pointer<ffi.Int>,
          int,
          ffi.Pointer<ffi.Char>,
          int,
          int,
          int,
          FetchEntryTableCallback,
          FetchChainTableCallback)>();

  /// # Safety
  /// cannot be safe since using FFI
  int h_compact(
    int number_of_reindexing_phases_before_full_set,
    ffi.Pointer<ffi.Char> master_keys_ptr,
    ffi.Pointer<ffi.Int> label_ptr,
    int label_len,
    FetchEntryTableCallback fetch_entry,
    FetchChainTableCallback fetch_chain,
    FetchAllEntryTableCallback fetch_all_entry,
    UpdateLinesCallback update_lines,
    ListRemovedLocationsCallback list_removed_locations,
  ) {
    return _h_compact(
      number_of_reindexing_phases_before_full_set,
      master_keys_ptr,
      label_ptr,
      label_len,
      fetch_entry,
      fetch_chain,
      fetch_all_entry,
      update_lines,
      list_removed_locations,
    );
  }

  late final _h_compactPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              ffi.Int,
              ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Int>,
              ffi.Int,
              FetchEntryTableCallback,
              FetchChainTableCallback,
              FetchAllEntryTableCallback,
              UpdateLinesCallback,
              ListRemovedLocationsCallback)>>('h_compact');
  late final _h_compact = _h_compactPtr.asFunction<
      int Function(
          int,
          ffi.Pointer<ffi.Char>,
          ffi.Pointer<ffi.Int>,
          int,
          FetchEntryTableCallback,
          FetchChainTableCallback,
          FetchAllEntryTableCallback,
          UpdateLinesCallback,
          ListRemovedLocationsCallback)>();

  /// Get the most recent error as utf-8 bytes, clearing it in the process.
  /// # Safety
  /// - `error_msg`: must be pre-allocated with a sufficient size
  int get_last_error(
    ffi.Pointer<ffi.Char> error_msg_ptr,
    ffi.Pointer<ffi.Int> error_len,
  ) {
    return _get_last_error(
      error_msg_ptr,
      error_len,
    );
  }

  late final _get_last_errorPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Int>)>>('get_last_error');
  late final _get_last_error = _get_last_errorPtr
      .asFunction<int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Int>)>();
}

typedef FetchEntryTableCallback = ffi.Pointer<
    ffi.NativeFunction<
        ffi.Int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.UnsignedInt>,
            ffi.Pointer<ffi.UnsignedChar>, ffi.UnsignedInt)>>;
typedef UpdateEntryTableCallback = ffi.Pointer<
    ffi.NativeFunction<
        ffi.Void Function(ffi.Pointer<ffi.UnsignedChar>, ffi.UnsignedInt)>>;
typedef UpdateChainTableCallback = ffi.Pointer<
    ffi.NativeFunction<
        ffi.Void Function(ffi.Pointer<ffi.UnsignedChar>, ffi.UnsignedInt)>>;
typedef FetchChainTableCallback = ffi.Pointer<
    ffi.NativeFunction<
        ffi.Int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.UnsignedInt>,
            ffi.Pointer<ffi.UnsignedChar>, ffi.UnsignedInt)>>;

/// # Return
///
/// - 0: all done
/// - 1: ask again for more entries
/// - _: error
typedef FetchAllEntryTableCallback = ffi.Pointer<
    ffi.NativeFunction<
        ffi.Int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.UnsignedInt>,
            ffi.UnsignedInt)>>;
typedef UpdateLinesCallback = ffi.Pointer<
    ffi.NativeFunction<
        ffi.Int Function(
            ffi.Pointer<ffi.UnsignedChar>,
            ffi.UnsignedInt,
            ffi.Pointer<ffi.UnsignedChar>,
            ffi.UnsignedInt,
            ffi.Pointer<ffi.UnsignedChar>,
            ffi.UnsignedInt)>>;
typedef ListRemovedLocationsCallback = ffi.Pointer<
    ffi.NativeFunction<
        ffi.Int Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.UnsignedInt>,
            ffi.Pointer<ffi.UnsignedChar>, ffi.UnsignedInt)>>;

const int WORD_HASH_LENGTH = 32;

const int ENTRY_TABLE_UID_SIZE = 32;

const int CHAIN_TABLE_VALUE_SIZE = 60;