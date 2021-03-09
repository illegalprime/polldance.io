defmodule VoteWeb.BallotLive do
  use VoteWeb, :live_view
  alias Phoenix.PubSub
  alias Vote.Ballots
  alias Vote.Ballots.LiveState
  alias Vote.Ballots.BallotItem
  alias Vote.Token

  def ok(socket), do: {:ok, socket}
  def noreply(socket), do: {:noreply, socket}

  @impl true
  def mount(%{"ballot" => token}, _session, socket) do
    with {:ok, id} <- Token.verify_ballot_token(token) do
      LiveState.register(id)

      topic = "ballot/#{id}/update"
      PubSub.subscribe(Vote.PubSub, topic)

      ballot = Ballots.by_id(id)

      socket
      |> assign(topic: topic)
      |> assign(ballot: ballot)
      |> assign(page_title: ballot.title)
      |> assign(options_valid: %{})
      |> ok()
    else
      _ -> socket
      |> put_flash(:error, "Invalid or expired (100 days) ballot link.")
      |> redirect(to: Routes.homepage_path(socket, :index))
      |> ok()
    end
  end

  @impl true
  def handle_event("add_option", %{"add_option" => info}, socket) do
    idx = String.to_integer(info["idx"])
    item_id = Enum.at(socket.assigns.ballot.ballot_items, idx).id
    option = String.trim(info["option"])

    socket
    |> broadcast_listener({:add_option, item_id, option})
    |> noreply()
  end

  @impl true
  def handle_event("add_option_validate", %{"add_option" => info}, socket) do
    idx = String.to_integer(info["idx"])
    item = Enum.at(socket.assigns.ballot.ballot_items, idx)
    valid? = BallotItem.option_valid(item.options, info["option"])
    options_valid = Map.put(socket.assigns.options_valid, idx, valid?)

    socket
    |> assign(options_valid: options_valid)
    |> noreply()
  end

  @impl true
  def handle_info(:update, socket) do
    socket
    |> assign(ballot: Ballots.by_id(socket.assigns.ballot.id))
    |> noreply()
  end

  def broadcast_listener(socket, data) do
    id = socket.assigns.ballot.id
    PubSub.broadcast(Vote.PubSub, "ballot/#{id}/listener", data)
    socket
  end
end
