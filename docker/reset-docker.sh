docker compose down --volumes --remove-orphans
docker compose stop
docker system prune --all --volumes --force
