defmodule Schemas.Game do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Poison.Encoder, only: [:lobby_number, :time_started, :time_ended, :winner, :players]}
  schema "games" do
      field :lobby_number, :integer
      field :time_started, :string
      field :time_ended, :string
      field :winner, :id
      field :players, {:array, :id}
  end

  def changeset(game, params \\ %{}) do
    game |>
    cast(params, [:lobby_number, :time_started, :time_ended, :winner, :players]) |>
    validate_required([:lobby_number, :time_started, :time_ended, :winner, :players]) |>
    unique_constraint(:lobby_number)
  end
end
