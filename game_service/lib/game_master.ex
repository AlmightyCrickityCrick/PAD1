defmodule GameMaster do
  use GenServer

  def start_link(args) do
    IO.puts("Starting server #{Map.get(args, :name)}")
    GenServer.start_link(__MODULE__, args, name: Map.get(args, :name))
  end

  def init(init_arg) do
    players = Map.get(init_arg, :players)
    table_deck = get_full_deck()
    {:ok,
    %{name: Map.get(init_arg, :name),
    type: Map.get(init_arg, :type),
    players: players,
    current_player: List.first(players),
    decks: Map.new(),
    table_deck: table_deck,
    current_card: nil,
    started_time: DateTime.to_string(DateTime.utc_now()),
    orientation: :end }}

  end

  def handle_cast({:add_player, user_id}, state) do
    new_state = state |> Map.put(:players, [user_id | Map.get(state, :players)])
    IO.inspect(new_state)
    {:noreply, new_state}
  end

  def handle_call({:join, user_id}, _from, state) do
    if user_id in Map.get(state, :players) do
      {user_deck, table_deck} = create_user_deck(Map.get(state, :table_deck))
      new_decks = Map.get(state, :decks) |> Map.put(user_id, user_deck)
      new_state = state |> Map.put(:decks, new_decks) |> Map.put(:table_deck, table_deck)

      {:reply, %{status: :success, message: %{accepted: true, hand_cards: user_deck, next_user_id: state.current_player, current_card: state.current_card}}, new_state}
    else
      {:reply, %{status: :error, message: "You do not have access to this lobby. Please leave"}, state}
    end
  end

  def handle_call({:move, move}, _from, state) do
    {reply, new_state }=
      if(Map.get(move, "id") != state.current_player) do
        _ = GenServer.cast(GameMasterDirector, {:red, Map.get(move, "id")})
        {{:error, %{accepted: false, hand_cards: state.decks[move["id"]], current_card: state.current_card, next_user_id: state.current_player}},state}
      else
        ns = analyze_play(move, state)
        r = create_responses(ns)
        {{:success, r}, ns}
      end
    {:reply, reply, new_state}
  end

  def handle_call({:exit, user_id}, _from, state) do
    new_players = List.delete(state.players, user_id)
    new_decks = Map.delete(state.decks, user_id)
    new_current_player = if user_id == state.current_player do select_next_player(state) else state.current_player end
    new_historical_players = if Map.has_key?(state, :historic_players) do [user_id | state[:historic_players]] else [user_id] end
    new_state = state |> Map.put(:players, new_players) |> Map.put(:decks, new_decks) |> Map.put(:current_player, new_current_player) |>Map.put(:historic_players, new_historical_players)
    cond do
      length(new_players) == 0 ->
        _res = :ets.delete(:lobby_registry, state.name)
        send(self(), :die)
        {:reply, "", new_state}
      length(new_players) == 1 ->
        finalize_game(new_state, List.first(new_players))
        send(self(), :die)
        response = %{List.first(new_players) => %{accepted: true, next_user_id: nil, winner_id: List.first(new_players)}}
        {:reply, response, new_state}
      length(new_players) >= 2 ->
        GameMasterDirector.modifyRank(user_id, -10)
        response = create_responses(new_state)
        {:reply, response, new_state}
    end
  end

  def handle_info(:die, state) do
    {:stop, "Game finished", state}
  end

  def create_responses(state) do
    for x <- state.players, into: %{} do
      {x, %{accepted: true, hand_cards: Map.get(state[:decks], x), current_card: state.current_card, next_user_id: state.current_player}}
    end
  end

  def select_next_player(state) do
    player_id = Enum.find_index(state[:players], state.current_player)
    if (state.orientation == :end) do
      Enum.at(state[:players], player_id + 1, List.first(state[:players]))
    else
      Enum.at(state[:players], player_id - 1)
    end
  end

  def create_user_deck(table_deck) do
    user_deck = Enum.take_random(table_deck, 7)
    previous_deck = table_deck
    new_deck = Enum.reduce(user_deck, previous_deck, fn x, acc ->
      List.delete(acc, x)
    end  )
    {user_deck, new_deck}
  end

  def take_cards(table_deck, nr) do
    user_deck = Enum.take_random(table_deck, nr)
    previous_deck = table_deck
    new_deck = Enum.reduce(user_deck, previous_deck, fn x, acc ->
      List.delete(acc, x)
    end  )
    {user_deck, new_deck}
  end

  #TODO: Analyze play
  def analyze_play(move, state) do
    # Check if card is put or taken
    cond do
      "take_card" in move["move"] ->
        nr = String.replace(move["move"], "take_card_", "") |> String.to_integer()
        {new_cards, new_table}= take_cards(state.table_deck , nr)
        new_current_player = select_next_player(state)
        user_new_deck = Map.get(state.decks, move["id"]) ++ new_cards
        all_new_decks = state.decks |> Map.put(move["id"], user_new_deck)
        state |>
        Map.put(:current_player, new_current_player) |>
        Map.put(:table_deck, new_table) |>
        Map.put(:decks, all_new_decks)
      move["move"] == "put_card" ->
        user_new_deck = state.decks[move["id"]] |> List.delete(move["card"])
        new_rest_state = if move["card"] in ["plus4", "plus4", "plus4", "plus4", "color_change", "color_change", "color_change", "color_change"] do
          cond do
            move["card"] == "plus4" ->
              {new_cards, new_table}= take_cards(state.table_deck , 4)
              loser_new_deck = state.decks[select_next_player(state)] ++ new_cards
              all_new_decks = state.decks |> Map.put(select_next_player(state), loser_new_deck)
              state |>
              Map.put(:current_card, move["color"]) |>
              Map.put(:table_deck, new_table)|>
              Map.put(:current_player, select_next_player(state)) |>
              Map.put(:current_player, select_next_player(state)) |>
              Map.put(:decks, all_new_decks)

            move["card"] == "color_change" ->
              state |> Map.put(:current_card, move["color"])

          end
        else
          [first, last] = String.split(move["card"], "_")
          if (first in state.current_card or last in state.current_card or state.current_card == nil) do
            state |>
            Map.put(:current_player, select_next_player(state)) |>
            Map.put(:current_card, move["card"])
          end

        end
        all_new_decks = new_rest_state.decks |> Map.put(move["id"], user_new_deck)
        new_rest_state |> Map.put(:decks, all_new_decks)

      true ->
        state
    end
  end

  def finalize_game(state, winner) do
    p = if Map.has_key?(state, :historic_players) do state.historic_players ++ state.players else state.players end
    GenServer.cast(GameMasterDirector, {:finalize, %{lobby: state.name, players: p, started_time: state.started_time, winner: winner }})
  end


  def get_full_deck do
    colors = ["red", "blue", "green", "yellow"]
    nominal = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "skip", "draw", "plus2"]
    simple_cards = for i <- colors, j <- nominal do
      "#{i}_#{j}"
    end
    simple_cards2 = for i <- colors, j <- nominal do
      "#{i}_#{j}"
    end
    wild_cards = ["plus4", "plus4", "plus4", "plus4", "color_change", "color_change", "color_change", "color_change"]
    Enum.concat(simple_cards, simple_cards2) |> Enum.concat(wild_cards)
  end

end
