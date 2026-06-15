docker compose down
docker run --rm -v iris-prod_iris-data:/iris-data ubuntu \
  bash -c "chown -R 51773:51773 /iris-data && chmod -R u+rwX /iris-data"

cp .env.test .env
docker compose up -d 
cp .env.public .env