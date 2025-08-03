test:
    docker compose -f docker-compose.test.yml up --build --abort-on-container-exit --no-log-prefix
    docker compose -f docker-compose.test.yml down --remove-orphans