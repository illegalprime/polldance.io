defmodule VoteWeb.BallotLive do
  use VoteWeb, :live_view
  alias Phoenix.PubSub
  alias Vote.Ballots
  alias Vote.Ballots.LiveState
  alias Vote.Ballots.ResponseSet
  alias Vote.Token

  def ok(socket), do: {:ok, socket}
  def noreply(socket), do: {:noreply, socket}

  @impl true
  def mount(%{"ballot" => token}, session, socket) do
    with {:ok, id} <- Token.verify_ballot_token(token) do
      {:ok, user} = VoteWeb.Authentication.load_user(session)
      LiveState.register(id)
      PubSub.subscribe(Vote.PubSub, "ballot/#{id}/update")

      ballot = Ballots.by_id(id)
      prev_resp = %ResponseSet{}  # TODO: load

      socket
      |> assign(cs: ResponseSet.changeset(prev_resp, %{}, ballot, user))
      |> assign(response_set: prev_resp)
      |> assign(user: user)
      |> ok()
    else
      _ -> socket
      |> put_flash(:error, "Invalid or expired (100 days) ballot link.")
      |> redirect(to: Routes.homepage_path(socket, :index))
      |> ok()
    end
  end

  @impl true
  def handle_event("add_option", %{"option" => option, "idx" => idx}, socket) do
    idx = String.to_integer(idx)
    item_id = Enum.at(socket.assigns.cs.data.ballot.ballot_items, idx).id
    option = String.trim(option)

    socket
    |> broadcast_listener({:add_option, item_id, option})
    |> noreply()
  end

  @impl true
  def handle_event("vote_change", %{"response_set" => params}, socket) do
    assign(socket, cs: update_cs(socket, params)) |> noreply()
  end

  @impl true
  def handle_event("vote_submit", %{"response_set" => _params}, _socket) do
    # cs = update_cs(socket, params))
  end

  # TODO: what if someone is mid-drag while something is appended?
  @impl true
  def handle_info({:update_item, item_id}, socket) do
    socket.assigns.cs
    |> ResponseSet.update_item(item_id)
    |> (fn cs -> assign(socket, cs: cs) end).()
    |> noreply()
  end

  def update_cs(socket, params) do
    # update to new ballot in case it was changed
    ballot = Ballots.by_id(socket.assigns.cs.data.ballot.id)
    # get the current user from the socket
    user = socket.assigns.user
    # get the yet-to-be edited response set
    # TODO: should this be re-gotten? user voting from multiple windows?
    response_set = socket.assigns.response_set
    # make a new change set from these
    ResponseSet.changeset(response_set, params, ballot, user)
  end

  def broadcast_listener(socket, data) do
    id = socket.assigns.cs.data.ballot.id
    PubSub.broadcast(Vote.PubSub, "ballot/#{id}/listener", data)
    socket
  end
end
