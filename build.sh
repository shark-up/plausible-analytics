#!/usr/bin/env bash
# exit on error
set -o errexit

echo "🚀 Let's build Plausible for $MIX_ENV"

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

mix local.hex --force
mix local.rebar --force
mix deps.get --only prod
echo "✅ Get deps of Elixir"

MIX_ENV=prod mix compile
echo "✅ Compile Beam"

mix ecto.create
mix ecto.migrate
echo "✅ Update database"

echo "✨ Build done ✨"