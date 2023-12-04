defmodule RankingStrategy do
  import Ecto.Query


  def get_user(usr_id) do
    repo = GenServer.call(DatabaseTracker, {:replica})
    try do
      repo.get(Schemas.Player, usr_id)
    rescue
      _ -> nil
    end
  end

  def login(email, password) do
    repo = GenServer.call(DatabaseTracker, {:replica})
    try do
      user = repo.one!(from u in Schemas.Player, where: u.email == ^email and u.password == ^password)
      addUserToCache(user)
      user
    rescue
      _ ->
        IO.puts("Oh no! User doesnt exist!")
        nil
    end
  end

  def addUserToCache(user) do
    IO.puts("Trying to add to Cache")
    # result = RedisCache.command!(["SET", user.id, Poison.encode!(user), "EX", 3600], user.id)
    result = RedisCache.put(user.id, Poison.encode!(user))
    r = RedisCache.expire(user.id, 3600000)
    IO.inspect(result)
   end

  def register(player) do
    repo = GenServer.call(DatabaseTracker, {:repo})
    try do
      changeset = Schemas.Player.changeset(%Schemas.Player{}, %{
        username: Map.get(player, "username"),
        password: Map.get(player, "password"),
        email: Map.get(player, "email"),
        })
        IO.inspect(changeset)
      {_result, user} = repo.insert(changeset)
      r = addUserToCache(user)
      IO.inspect(user)
      user
    rescue
      _ -> nil
    end
  end

  def get_friends(user_id) do
    repo = GenServer.call(DatabaseTracker, {:repo})
    query = from u in Schemas.Player, join: f in Schemas.Friend, on: [user_id: u.id], select: f.friend_id
    friend_ids = repo.all(query)
    IO.puts("Friends Id")
    IO.inspect(friend_ids)

    friend_players = Schemas.Player|> where([p], p.id in ^friend_ids) |> repo.all()
    IO.puts("Friends all")
    IO.inspect(friend_players)
    friend_players
  end

  def add_friend(user_id, friend_id) do
    repo = GenServer.call(DatabaseTracker, {:repo})
    user = get_user(user_id)
    friend = get_user(friend_id)
    if (user == nil or friend == nil) do
      :error
    else
      new_friendship = %Schemas.Friend{user_id: user_id, friend_id: friend_id}
      result = repo.insert(new_friendship)
      new_user = user |> Schemas.Player.changeset(%{friends: [friend]}) |> repo.update()
      new_friend = friend |> Schemas.Player.changeset(%{friends: [new_user]})|> repo.update()
      :ok
    end
  end

  def delete_friend(user_id, friend_id) do
    repo = GenServer.call(DatabaseTracker, {:repo})

    friendship = repo.one(from u in Schemas.Friend, where: u.user_id == ^user_id and u.friend_id == ^friend_id)
    if friendship != nil do repo.delete(friendship) end

    user = get_user(user_id) |> repo.preload(:friends)
    friend = get_user(friend_id) |> repo.preload(:friends)

    if (user == nil or friend == nil) do
      :error
    else
      new_user = user |> Schemas.Player.changeset(%{friends: List.delete(user.friends, friend)}) |> repo.update()
      new_friend = friend |> Schemas.Player.changeset(%{friends: List.delete(friend.friends, new_user)})|> repo.update()
      :ok
    end

  end

  def change_rank(user_id, value) do
    repo = GenServer.call(DatabaseTracker, {:repo})
    user = get_user(user_id)
    if user == nil do
      nil
    else
    changeset = user |> Schemas.Player.changeset(%{rank: user.rank + value})
    IO.inspect(changeset)
    {_success, new_user} =  changeset|> repo.update()
    addUserToCache(new_user)
    :ok
    end
  end

  def ban_user(user_id) do
    repo = GenServer.call(DatabaseTracker, {:repo})

    user = get_user(user_id)
    {_success, new_user} = user |> Schemas.Player.changeset(%{is_banned: true}) |> repo.update()
    addUserToCache(new_user)
    :ok
  end


end
