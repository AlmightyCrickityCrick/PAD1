defmodule Schemas.PlayerEvo do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Poison.Encoder, only: [:id, :user_id, :rank, :is_banned]}
  schema "players_evo" do
      field :user_id, :integer
      field :rank, :integer, default: 1
      field :is_banned, :boolean, default: false
      field :time, :string
  end

  def changeset(player, params \\ %{}) do
    player |>
    cast(params, [:user_id, :rank, :is_banned, :time]) |>
    validate_required([:user_id, :rank, :is_banned, :time])
  end
end
