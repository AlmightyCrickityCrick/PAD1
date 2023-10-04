defmodule GameMaster do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: Map.get(args, :name))
  end

  def init(init_arg) do
    players = Map.get(init_arg, :players)

    table_deck = get_full_deck()

    #TODO: Figure out how to take card from inside deck when head fresher

    # deck1 = Enum.take_random(table_deck, 7)
    # to_be_deleted = for card <- deck1 do
    #   Enum.find_index(table_index, )
    # end


    #Creates the decks
    decks = for p <- players do
      %{p => Enum.take_random(table_deck, 7)}
    end

    {:ok, %{type: Map.get(init_arg, :type), players: players, current_player: List.first(players),  decks: decks, table_deck: table_deck, current_card: nil, orientation: :end }}

  end

  #TODO: Handle users joining depending on lobby type
  def handle_call({:join, id}, _from, state) do

    {:reply, "", state}
  end

  def handle_call({:move, move}, _from, state) do
    reply =
      if(Map.get(move, "id") != state.current_player) do
        nil
      else
        analyze_play(move, state)
      end
    {:reply, reply, state}
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
