defmodule Schemas.Player do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Poison.Encoder, only: [:id, :username, :email, :rank, :is_banned]}
  schema "players" do
      field :username, :string
      field :password, :string
      field :email, :string
      field :rank, :integer, default: 1
      field :is_banned, :boolean, default: false
      many_to_many :friends, Schemas.Player, join_through: Schema.Friend, join_keys: [user_id: :id, friend_id: :id]
  end

  def changeset(player, params \\ %{}) do
    player |>
    cast(params, [:username, :password, :email]) |>
    validate_required([:username, :email, :password]) |>
    unique_constraint(:email) |>
    validate_format(:email, ~r/@/) |>
    unique_constraint(:username)
  end
end
