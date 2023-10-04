defmodule Schemas.Friend do
  use Ecto.Schema
  # import Ecto.Changeset

  @derive {Poison.Encoder, only: [:user_id, :friend_id]}
  schema "friends "do
    field :user_id, :id
    field :friend_id, :id

    timestamps()
  end

  # def changeset(player, params \\ %{}) do
  #   player |> cast(params, [:friend_id]) |> validate_request([:friend_id])
  # end
end
