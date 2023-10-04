defmodule RankingStrategy do
  import Ecto.Query
  def get_user(usr_id) do
    try do
      Players.Repo.get(Schemas.Player, usr_id)
    rescue
      _ -> nil
    end
  end

  def login(email, password) do
    try do
      user = Players.Repo.one!(from u in Schemas.Player, where: u.email == ^email and u.password == ^password)
      user
    rescue
      _ -> nil
    end

  end

  def register(player) do
    try do
      changeset = Schemas.Player.changeset(%Schemas.Player{}, %{
        username: Map.get(player, "username"),
        password: Map.get(player, "password"),
        email: Map.get(player, "email"),
        })
      {_result, user} = Players.Repo.insert(changeset)
      IO.inspect(user)
      user
    rescue
      _ -> nil
    end
  end


end
