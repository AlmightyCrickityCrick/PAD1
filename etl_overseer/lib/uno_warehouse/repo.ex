defmodule UnoWarehouse.Repo do
  use Ecto.Repo,
    otp_app: :etl_overseer,
    adapter: Ecto.Adapters.Postgres
end
