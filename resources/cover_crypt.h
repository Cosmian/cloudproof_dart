// NOTE: Autogenerated file

#define MAX_CLEAR_TEXT_SIZE (1 << 30)

/**
 * Externally set the last error recorded on the Rust side
 *
 * # Safety
 * This function is meant to be called from the Foreign Function
 * Interface
 */
int32_t set_error(const char *error_message_ptr);

/**
 * Get the most recent error as utf-8 bytes, clearing it in the process.
 * # Safety
 * - `error_msg`: must be pre-allocated with a sufficient size
 */
int get_last_error(char *error_msg_ptr, int *error_len);

/**
 * Generate the master authority keys for supplied Policy
 *
 *  - `master_keys_ptr`    : Output buffer containing both master keys
 *  - `master_keys_len`    : Size of the output buffer
 *  - `policy_ptr`         : Policy to use to generate the keys
 * # Safety
 */
int h_generate_master_keys(char *master_keys_ptr, int *master_keys_len, const char *policy_ptr);

/**
 * Generate the user secret key matching the given access policy
 *
 * - `usk_ptr`             : Output buffer containing user secret key
 * - `usk_len`             : Size of the output buffer
 * - `msk_ptr`             : Master secret key (required for this generation)
 * - `msk_len`             : Master secret key length
 * - `access_policy_ptr`   : Access policy of the user secret key (JSON)
 * - `policy_ptr`          : Policy to use to generate the keys (JSON)
 * # Safety
 */
int h_generate_user_secret_key(char *usk_ptr,
                               int *usk_len,
                               const char *msk_ptr,
                               int msk_len,
                               const char *access_policy_ptr,
                               const char *policy_ptr);

/**
 * Rotate the attributes of the given policy
 *
 * - `updated_policy_ptr`  : Output buffer containing new policy
 * - `updated_policy_len`  : Size of the output buffer
 * - `attributes_ptr`      : Attributes to rotate (JSON)
 * - `policy_ptr`          : Policy to use to generate the keys (JSON)
 * # Safety
 */
int h_rotate_attributes(char *updated_policy_ptr,
                        int *updated_policy_len,
                        const char *attributes_ptr,
                        const char *policy_ptr);

/**
 * Update the master keys according to this new policy.
 *
 * When a partition exists in the new policy but not in the master keys,
 * a new key pair is added to the master keys for that partition.
 * When a partition exists on the master keys, but not in the new policy,
 * it is removed from the master keys.
 *
 * - `updated_msk_ptr` : Output buffer containing the updated master secret key
 * - `updated_msk_len` : Size of the updated master secret key output buffer
 * - `updated_mpk_ptr` : Output buffer containing the updated master public key
 * - `updated_mpk_len` : Size of the updated master public key output buffer
 * - `current_msk_ptr` : current master secret key
 * - `current_msk_len` : current master secret key length
 * - `current_mpk_ptr` : current master public key
 * - `current_mpk_len` : current master public key length
 * - `policy_ptr`      : Policy to use to update the master keys (JSON)
 * # Safety
 */
int h_update_master_keys(char *updated_msk_ptr,
                         int *updated_msk_len,
                         char *updated_mpk_ptr,
                         int *updated_mpk_len,
                         const char *current_msk_ptr,
                         int current_msk_len,
                         const char *current_mpk_ptr,
                         int current_mpk_len,
                         const char *policy_ptr);

/**
 * Refresh the user key according to the given master key and access policy.
 *
 * The user key will be granted access to the current partitions, as determined
 * by its access policy. If `preserve_old_partitions` is set, the user access to
 * rotated partitions will be preserved
 *
 * - `updated_usk_ptr`                 : Output buffer containing the updated
 *   user secret key
 * - `updated_usk_len`                 : Size of the updated user secret key
 *   output buffer
 * - `msk_ptr`                         : master secret key
 * - `msk_len`                         : master secret key length
 * - `current_usk_ptr`                 : current user secret key
 * - `current_usk_len`                 : current user secret key length
 * - `access_policy_ptr`               : Access policy of the user secret key
 *   (JSON)
 * - `policy_ptr`                      : Policy to use to update the master
 *   keys (JSON)
 * - `preserve_old_partitions_access`  : set to 1 to preserve the user access
 *   to the rotated partitions
 * # Safety
 */
int h_refresh_user_secret_key(char *updated_usk_ptr,
                              int *updated_usk_len,
                              const char *msk_ptr,
                              int msk_len,
                              const char *current_usk_ptr,
                              int current_usk_len,
                              const char *access_policy_ptr,
                              const char *policy_ptr,
                              int preserve_old_partitions_access);

/**
 * Converts a boolean expression containing an access policy
 * into a JSON access policy which can be used in Vendor Attributes
 *
 * Note: the return string is NULL terminated
 *
 * - `json_access_policy_ptr`: Output buffer containing a null terminated
 *   string with the JSON access policy
 * - `json_access_policy_len`: Size of the output buffer
 * - `boolean_access_policy_ptr`: boolean access policy string
 * # Safety
 */
int h_parse_boolean_access_policy(char *json_access_policy_ptr,
                                  int *json_access_policy_len,
                                  const char *boolean_access_policy_ptr);

/**
 * Create a cache of the Public Key and Policy which can be re-used
 * when encrypting multiple messages. This avoids having to re-instantiate
 * the public key on the Rust side on every encryption which is costly.
 *
 * This method is to be used in conjunction with
 *     `h_aes_encrypt_header_using_cache`
 *
 * WARN: `h_aes_destroy_encrypt_cache`() should be called
 * to reclaim the memory of the cache when done
 * # Safety
 */
int32_t h_aes_create_encryption_cache(int *cache_handle,
                                      const char *policy_ptr,
                                      const char *pk_ptr,
                                      int pk_len);

/**
 * The function should be called to reclaim memory
 * of the cache created using `h_aes_create_encrypt_cache`()
 * # Safety
 */
int h_aes_destroy_encryption_cache(int cache_handle);

/**
 * Encrypt a header using an encryption cache
 * The symmetric key and header bytes are returned in the first OUT parameters
 * # Safety
 */
int h_aes_encrypt_header_using_cache(char *symmetric_key_ptr,
                                     int *symmetric_key_len,
                                     char *header_bytes_ptr,
                                     int *header_bytes_len,
                                     int cache_handle,
                                     const char *encryption_policy_ptr,
                                     const char *additional_data_ptr,
                                     int additional_data_len,
                                     const char *authentication_data_ptr,
                                     int authentication_data_len);

/**
 * Encrypt a header without using an encryption cache.
 * It is slower but does not require destroying any cache when done.
 *
 * The symmetric key and header bytes are returned in the first OUT parameters
 * # Safety
 */
int h_aes_encrypt_header(char *symmetric_key_ptr,
                         int *symmetric_key_len,
                         char *header_bytes_ptr,
                         int *header_bytes_len,
                         const char *policy_ptr,
                         const char *pk_ptr,
                         int pk_len,
                         const char *encryption_policy_ptr,
                         const char *additional_data_ptr,
                         int additional_data_len,
                         const char *authentication_data_ptr,
                         int authentication_data_len);

/**
 * Create a cache of the User Decryption Key which can be re-used
 * when decrypting multiple messages. This avoids having to re-instantiate
 * the user key on the Rust side on every decryption which is costly.
 *
 * This method is to be used in conjunction with
 *     `h_aes_decrypt_header_using_cache`()
 *
 * WARN: `h_aes_destroy_decryption_cache`() should be called
 * to reclaim the memory of the cache when done
 * # Safety
 */
int32_t h_aes_create_decryption_cache(int *cache_handle, const char *usk_ptr, int usk_len);

/**
 * The function should be called to reclaim memory
 * of the cache created using `h_aes_create_decryption_cache`()
 * # Safety
 */
int h_aes_destroy_decryption_cache(int cache_handle);

/**
 * Decrypts an encrypted header using a cache.
 * Returns the symmetric key and additional data if available.
 *
 * No additional data will be returned if the `additional_data_ptr` is NULL.
 *
 * # Safety
 */
int h_aes_decrypt_header_using_cache(char *symmetric_key_ptr,
                                     int *symmetric_key_len,
                                     char *additional_data_ptr,
                                     int *additional_data_len,
                                     const char *encrypted_header_ptr,
                                     int encrypted_header_len,
                                     const char *authentication_data_ptr,
                                     int authentication_data_len,
                                     int cache_handle);

/**
 * Decrypts an encrypted header, returning the symmetric key and additional
 * data if available.
 *
 * Slower than using a cache but avoids handling the cache creation and
 * destruction.
 *
 * No additional data will be returned if the `additional_data_ptr` is NULL.
 *
 * # Safety
 */
int h_aes_decrypt_header(char *symmetric_key_ptr,
                         int *symmetric_key_len,
                         char *additional_data_ptr,
                         int *additional_data_len,
                         const char *encrypted_header_ptr,
                         int encrypted_header_len,
                         const char *authentication_data_ptr,
                         int authentication_data_len,
                         const char *usk_ptr,
                         int usk_len);

/**
 *
 * # Safety
 */
int h_aes_symmetric_encryption_overhead(void);

/**
 *
 * # Safety
 */
int h_aes_encrypt_block(char *ciphertext_ptr,
                        int *ciphertext_len,
                        const char *symmetric_key_ptr,
                        int symmetric_key_len,
                        const char *authentication_data_ptr,
                        int authentication_data_len,
                        const char *plaintext_ptr,
                        int plaintext_len);

/**
 *
 * # Safety
 */
int h_aes_decrypt_block(char *plaintext_ptr,
                        int *plaintext_len,
                        const char *symmetric_key_ptr,
                        int symmetric_key_len,
                        const char *authentication_data_ptr,
                        int authentication_data_len,
                        const char *encrypted_bytes_ptr,
                        int encrypted_bytes_len);

/**
 * Hybrid encrypt some content
 * # Safety
 */
int h_aes_encrypt(char *ciphertext_ptr,
                  int *ciphertext_len,
                  const char *policy_ptr,
                  const char *pk_ptr,
                  int pk_len,
                  const char *encryption_policy_ptr,
                  const char *plaintext_ptr,
                  int plaintext_len,
                  const char *additional_data_ptr,
                  int additional_data_len,
                  const char *authentication_data_ptr,
                  int authentication_data_len);

/**
 * Hybrid decrypt some content
 *
 * # Safety
 */
int h_aes_decrypt(char *plaintext_ptr,
                  int *plaintext_len,
                  char *additional_data_ptr,
                  int *additional_data_len,
                  const char *ciphertext_ptr,
                  int ciphertext_len,
                  const char *authentication_data_ptr,
                  int authentication_data_len,
                  const char *usk_ptr,
                  int usk_len);

/**
 * Convert a boolean access policy expression into a
 * json expression that can be used to create a key using
 * the KMIP interface
 *
 * Returns
 *  - 0 if success
 *  - 1 in case of unrecoverable error
 *  - n if the return buffer is too small and should be of size n (including
 *    the NULL byte)
 *
 * `json_expr_len` contains the length of the JSON string on return
 *  (including the terminating NULL byte)
 *
 * # Safety
 */
int h_access_policy_expression_to_json(char *json_expr_ptr,
                                       int *json_expr_len,
                                       const char *boolean_expression_ptr);

extern void log(const str *s);

extern void alert(const str *s);