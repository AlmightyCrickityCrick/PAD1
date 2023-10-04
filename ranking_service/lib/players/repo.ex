defmodule Players.Repo do
  use Ecto.Repo,
  otp_app: :ranking_service,
  adapter: Ecto.Adapters.Postgres
  
end
