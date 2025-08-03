\set ECHO ALL
\set ON_ERROR_STOP ON

\c testdb testuser

\i /tests/install_pgtap.sql
\i /tests/01_ulid_extension_tests.sql
