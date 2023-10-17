defmodule GameMaster do
  use GenServer

  def start_link(args) do
    IO.puts("Starting server #{Map.get(args, :name)}")
    GenServer.start_link(__MODULE__, args, name: Map.get(args, :name))
  end

  def init(init_arg) do
    players = Map.get(init_arg, :players)
    table_deck = get_full_deck()
    {:ok, %{type: Map.get(init_arg, :type), players: players, current_player: List.first(players),  decks: Map.new(), table_deck: table_deck, current_card: nil, orientation: :end }}

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

      #TODO: Format the message send to user upon connection (his deck)
      {:reply, %{status: :success, message: %{accepted: true, hand_cards: user_deck, next_user_id: state.current_player, current_card: state.current_card}}, new_state}
    else
      {:reply, %{status: :error, message: "You do not have access to this lobby. Please leave"}, state}
    end
  end

  def handle_call({:move, move}, _from, state) do
    reply =
      if(Map.get(move, "id") != state.current_player) do
        _ = GenServer.cast(GameMasterDirector, {:red, Map.get(move, "id")})
        nil
      else
        analyze_play(move, state)
      end
    {:reply, reply, state}
  end

  def handle_call({:exit, user_id}, _from, state) do
    reply = nil
    {:reply, reply, state}
  end

  def create_user_deck(table_deck) do
    user_deck = Enum.take_random(table_deck, 7)
    previous_deck = table_deck
    new_deck = Enum.reduce(user_deck, previous_deck, fn x, acc ->
      List.delete(acc, x)
    end  )
    {user_deck, new_deck}
  end

  #TODO: Analyze play
  def analyze_play(move, state) do
    nil
    # Check if card is put or taken

    # If put, check if it satisfies the current_card
      # If it satisfies send back {:put, current_card}
      # and modify the deck of the user, next user to play and the table deck value

      #Dont forget to analyze the special cards, that are supposed to change the
      # orientation, color and add2 and 4 for the next user on the orientation

    #If taken, send back {:taken, :card_value}, delete that card from table deck
    # and add to user deck, increment next user to play

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
