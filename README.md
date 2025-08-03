
---

PostgreSQL image with the [`pgx_ulid`](https://github.com/pksunkara/pgx_ulid) extension pre-installed.

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

> Refer to the [pgx_ulid](https://github.com/pksunkara/pgx_ulid) repository for more details on how to use the extension.

## Supported tags

| Tag        | PostgreSQL | pgx_ulid |
|------------|------------|----------|
| `latest`   | 17         | 0.2.0    |


## Test suite

This project includes a test suite using [pgTAP](https://pgtap.org/) and Docker Compose. To run the tests, use [just](https://just.systems/):

```bash
just test
```

## License

This project is licensed under the [MIT License](LICENSE).