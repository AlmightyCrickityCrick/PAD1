defmodule GameHistory.Repo do
  use Ecto.Repo,
    otp_app: :game_service,
    adapter: Ecto.Adapters.Postgres
end
