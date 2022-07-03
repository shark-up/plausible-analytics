#!/usr/bin/env bash
# exit on error
set -o errexit

echo "🚀 Let's build Plausible for $MIX_ENV"

curl --silent --output /dev/null --write-out "%{http_code}" $CLICKHOUSE_URL

mix local.rebar --force
echo "✅ Install rebar3"
mix local.hex --force
echo "✅ Install hex"

mix deps.get --only prod
echo "✅ Get deps of Elixir"

MIX_ENV=prod mix compile
echo "✅ Compile Beam"

CLICKHOUSE_URL="http://$CLICKHOUSE_DATABASE_HOST:8123"
echo "Check clickhouse service availibility on $CLICKHOUSE_URL"

# RESP=$(curl --silent --output /dev/null --write-out "%{http_code}" $CLICKHOUSE_URL)

# echo $RESP
# n=0
# until [ "$n" -ge 6 ]; do
#   RESP=$(curl --silent --output /dev/null --write-out "%{http_code}\n" $CLICKHOUSE_URL)

#   if [ $RESP -eq "200" ]; then
#     break
#   fi

#   echo "Clickhouse service is unvailable ($RESP)"

#   echo "⏱️ Retry n°$n: Ping the Clickhouse service"

#   n=$((n+1)) 
#   sleep 10
# done
mix ecto.create
mix ecto.migrate
echo "✅ Databases"

npm install --prefix ./tracker
npm install --prefix ./assets
npm run deploy --prefix ./assets
npm run deploy --prefix ./tracker
mix phx.digest priv/static
echo "✅ Assets"

wget https://s3.eu-central-1.wasabisys.com/plausible-application/geonames.csv
mv geonames.csv ./priv/geonames.csv
echo "✅ geonames.csv"

mix download_country_database
echo "✅ Country Database"

echo "✨ Build done ✨"