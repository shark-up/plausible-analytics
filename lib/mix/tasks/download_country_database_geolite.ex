defmodule Mix.Tasks.DownloadCountryDatabaseGeolite do
  use Mix.Task
  use Plausible.Repo
  require Logger

  # coveralls-ignore-start

  def run(_) do
    Application.ensure_all_started(:httpoison)
    geolite_country_url = "https://cdn.jsdelivr.net/npm/geolite2-city@1.0.0/GeoLite2-City.mmdb.gz"
    Logger.info("Downloading #{geolite_country_url}")
    res = HTTPoison.get!(geolite_country_url)

    if res.status_code == 200 do
      File.mkdir("priv/geodb")
      File.write!("priv/geodb/dbip-country.mmdb", res.body)
      Logger.info("Downloaded and saved the database successfully")
    else
      Logger.error("Unable to download and save the database. Response: #{inspect(res)}")
    end
  end
end
