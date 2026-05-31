-- ============================================================================
-- MODULE 3: CRYPTOGRAPHIC LAYER & DATA-AT-REST ENCRYPTION (AES-256)
-- ============================================================================

-- 1. Initialize the official PostgreSQL cryptographic extension
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 2. Refactor schema to introduce binary storage (BYTEA) for encrypted text
ALTER TABLE public.customers ADD COLUMN encrypted_national_id BYTEA;
ALTER TABLE public.customers ADD COLUMN encrypted_credit_card BYTEA;

-- 3. Execute bulk encryption using the general encrypt() cipher function
-- Algorithm used: AES (Advanced Encryption Standard) with a 256-bit structural key
UPDATE public.customers
SET 
    encrypted_national_id = encrypt(national_id::bytea, 'SuperSecretKey2026!'::bytea, 'aes'),
    encrypted_credit_card = encrypt(credit_card_number::bytea, 'SuperSecretKey2026!'::bytea, 'aes');

-- 4. Secure Purge: Instantly drop the unencrypted plaintext data columns from the disk
ALTER TABLE public.customers DROP COLUMN national_id;
ALTER TABLE public.customers DROP COLUMN credit_card_number;

-- ============================================================================
-- VALIDATION AND CRYPTOGRAPHIC EXPERIMENT QUERIES
-- ============================================================================

-- VERIFICATION 1: Raw Encrypted Output (Simulating a database leak or raw disk reading)
-- Expected Result: `encrypted_national_id` and `encrypted_credit_card` appear as unreadable binary hash.
SELECT full_name, encrypted_national_id, encrypted_credit_card FROM public.customers;

-- VERIFICATION 2: Decryption Pipeline using the Authorized Corporate Key
-- Expected Result: Beautifully returns original human-readable data strings.
SELECT 
    full_name,
    convert_from(decrypt(encrypted_national_id, 'SuperSecretKey2026!'::bytea, 'aes'), 'SQL_ASCII') AS decrypted_national_id,
    convert_from(decrypt(encrypted_credit_card, 'SuperSecretKey2026!'::bytea, 'aes'), 'SQL_ASCII') AS decrypted_credit_card
FROM public.customers;
