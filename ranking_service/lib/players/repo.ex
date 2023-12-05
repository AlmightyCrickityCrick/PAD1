defmodule Players.Repo do
  use Ecto.Repo,
  otp_app: :ranking_service,
  adapter: Ecto.Adapters.Postgres

  @replicas [
    Players.Repo.Replica1,
    Players.Repo.Replica2,
  ]

  def replica do
    Enum.random(@replicas)
  end

  for repo <- @replicas do
    defmodule repo do
      use Ecto.Repo,
        otp_app: :ranking_service,
        adapter: Ecto.Adapters.Postgres
    end
  end

end
