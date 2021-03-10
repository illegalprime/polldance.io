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
      |> assign(options_selection: %{})
      |> all_options_events(ballot)
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
    options_valid = Map.delete(socket.assigns.options_valid, idx)

    socket
    |> assign(options_valid: options_valid)
    |> broadcast_listener({:add_option, item_id, option})
    |> push_event("clear_add_option", %{form: info["form"]})
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
  def handle_event(
    "update_selection", %{"idx" => idx, "options" => opts}, socket
  ) do
    idx = String.to_integer(idx)
    selected = socket.assigns.options_selection
    item_id = Enum.at(socket.assigns.ballot.ballot_items, idx).id

    socket
    |> options_update_event(opts, idx)
    |> assign(options_selection: Map.put(selected, item_id, opts))
    |> noreply()
  end

  @impl true
  def handle_info({:update_item, item_id}, socket) do
    new_ballot = Ballots.by_id(socket.assigns.ballot.id)
    {item, idx} = new_ballot.ballot_items
    |> Enum.with_index()
    |> Enum.find(fn {item, _idx} -> item.id == item_id end)

    # get the source of truth of available options
    latest_set = MapSet.new(item.options)
    # get the order that the user ranked them last
    all_selections = socket.assigns.options_selection
    selected = Map.get(all_selections, item_id, [])
    # remove any that aren't in the new set of possible options
    |> Enum.filter(fn o -> MapSet.member?(latest_set, o) end)
    # get any new options that were added by users
    new = MapSet.difference(latest_set, MapSet.new(selected)) |> MapSet.to_list()
    # append new options last so they don't interfere with current selection
    new_selection = selected ++ new

    socket
    |> assign(ballot: new_ballot)
    |> options_update_event(new_selection, idx)
    |> assign(options_selection: Map.put(all_selections, item_id, new_selection))
    |> noreply()
  end

  def all_options_events(socket, ballot) do
    ballot.ballot_items
    |> Enum.with_index()
    |> Enum.reduce(socket, fn {item, idx}, socket ->
      options_update_event(socket, item.options, idx)
    end)
  end

  def options_update_event(socket, options, idx) do
    push_event(socket, "options/#{idx}/update", %{options: options})
  end

  def broadcast_listener(socket, data) do
    id = socket.assigns.ballot.id
    PubSub.broadcast(Vote.PubSub, "ballot/#{id}/listener", data)
    socket
  end
end
