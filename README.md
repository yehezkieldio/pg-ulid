
---

A lightweight PostgreSQL image that ships [`pgx_ulid`](https://github.com/pksunkara/pgx_ulid) extension pre-installed, so you can generate **ULIDs** (Universally-Unique Lexicographically-Sortable Identifiers) immediately after `docker run`.

## Quick start

```bash
# Pull the image
docker pull ghcr.io/yehezkieldio/pg-ulid:latest

# Start a container
docker run --name pg-ulid -e POSTGRES_PASSWORD=secret -p 5432:5432 -d ghcr.io/yehezkieldio/pg-ulid
```

Connect with any SQL client and:

```sql
-- Enable the pgx_ulid extension
CREATE EXTENSION IF NOT EXISTS pgx_ulid;

-- Generate a single ULID
SELECT gen_ulid();

-- In a table, use it as a default value for a primary key with a ULID type
CREATE TABLE users (
  id ulid NOT NULL DEFAULT gen_ulid() PRIMARY KEY,
  name text NOT NULL
);
```

## Supported tags

| Tag        | PostgreSQL | pgx_ulid |
|------------|------------|----------|
| `latest`   | 17         | 0.2.0    |


## Configuration

For advanced options (monotonicity, entropy size, etc.) see the [pgx_ulid docs](https://github.com/pksunkara/pgx_ulid#configuration).

## License

This project is licensed under the [MIT License](LICENSE).