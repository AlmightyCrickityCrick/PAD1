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
      addUserToCache(user)
      user
    rescue
      _ -> nil
    end
  end

  def addUserToCache(user) do
    result = Redix.command(:redix, ["SET", user.id, Poison.encode!(user), "EX", 3600])
    IO.inspect(result)
   end

  def register(player) do
    try do
      changeset = Schemas.Player.changeset(%Schemas.Player{}, %{
        username: Map.get(player, "username"),
        password: Map.get(player, "password"),
        email: Map.get(player, "email"),
        })
      {_result, user} = Players.Repo.insert(changeset)
      addUserToCache(user)
      IO.inspect(user)
      user
    rescue
      _ -> nil
    end
  end

  def get_friends(user_id) do
    query = from u in Schemas.Player, join: f in Schemas.Friend, on: [user_id: u.id], select: f.friend_id

    friend_ids = Players.Repo.all(query)
    IO.puts("Friends Id")
    IO.inspect(friend_ids)

    friend_players = Schemas.Player|> where([p], p.id in ^friend_ids) |> Players.Repo.all()
    IO.puts("Friends all")
    IO.inspect(friend_players)
    friend_players
  end

  def add_friend(user_id, friend_id) do
    user = get_user(user_id)
    friend = get_user(friend_id)
    if (user == nil or friend == nil) do
      :error
    else
      new_friendship = %Schemas.Friend{user_id: user_id, friend_id: friend_id}
      result = Players.Repo.insert(new_friendship)
      new_user = user |> Schemas.Player.changeset(%{friends: [friend]}) |> Players.Repo.update()
      new_friend = friend |> Schemas.Player.changeset(%{friends: [new_user]})|> Players.Repo.update()
      :ok
    end
  end

  def delete_friend(user_id, friend_id) do
    friendship = Players.Repo.one(from u in Schemas.Friend, where: u.user_id == ^user_id and u.friend_id == ^friend_id)
    if friendship != nil do Players.Repo.delete(friendship) end

    user = get_user(user_id) |> Players.Repo.preload(:friends)
    friend = get_user(friend_id) |> Players.Repo.preload(:friends)

    if (user == nil or friend == nil) do
      :error
    else
      new_user = user |> Schemas.Player.changeset(%{friends: List.delete(user.friends, friend)}) |> Players.Repo.update()
      new_friend = friend |> Schemas.Player.changeset(%{friends: List.delete(friend.friends, new_user)})|> Players.Repo.update()
      :ok
    end

  end

  def change_rank(usr_id, value) do

  end

  def ban_user(usr_id) do

  end


end
