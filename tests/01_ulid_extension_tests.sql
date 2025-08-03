\set TEST_CLIENT_MIN_MESSAGES WARNING

BEGIN;

DO $$
BEGIN
    IF current_setting('pgtap.subtest', true) IS NULL THEN
        PERFORM plan(7);
    END IF;
END;
$$;

CREATE EXTENSION IF NOT EXISTS ulid;

-- Test 1: Check if the 'ulid' extension exists.
SELECT has_extension('ulid', 'ulid extension should exist and be loadable');

-- Test 2: Check if the 'ulid' type itself exists.
SELECT has_type('ulid', 'ulid type should exist');

-- Test 3: Check if the 'gen_ulid()' function exists in the public schema.
SELECT has_function('public', 'gen_ulid', 'gen_ulid() function should exist in the public schema');

-- Test 4: Run the gen_ulid() function and validate the output format with a regex.
SELECT ok(
    (SELECT gen_ulid()::text ~ '^[0-7][0-9A-HJKMNP-TV-Z]{25}$'::text),
    'gen_ulid() should return a valid ULID string'
);

-- Test 5: Verify that a column with DEFAULT gen_ulid() works correctly on insert.
CREATE TEMP TABLE test_table (
    id ulid DEFAULT gen_ulid(),
    name text
);
INSERT INTO test_table (name) VALUES ('Test User');
-- We cast the id column to text for the regular expression match.
SELECT ok(
    (SELECT id IS NOT NULL AND id::text ~ '^[0-7][0-9A-HJKMNP-TV-Z]{25}$'::text FROM test_table),
    'DEFAULT gen_ulid() should create a valid ULID on insert'
);

-- Test 6: Verify that consecutive ULIDs are unique.
SELECT is(
    (SELECT gen_ulid() = gen_ulid()),
    false,
    'consecutive gen_ulid() calls should produce unique values'
);

-- Test 7: Verify that later-generated ULIDs are lexicographically greater.
DO $$
DECLARE
    ulid1 ulid;
    ulid2 ulid;
BEGIN
    SELECT gen_ulid() INTO ulid1;
    PERFORM pg_sleep(0.001);
    SELECT gen_ulid() INTO ulid2;
    PERFORM ok(ulid1 < ulid2, 'a later ulid should be greater than an earlier ulid');
END;
$$ LANGUAGE plpgsql;

SELECT finish();
ROLLBACK;