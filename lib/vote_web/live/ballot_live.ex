defmodule VoteWeb.BallotLive do
  use VoteWeb, :live_view
  alias Phoenix.PubSub
  alias Vote.Ballots
  alias Vote.Ballots.LiveState
  alias Vote.Ballots.ResponseSet
  alias Vote.Voting
  alias Vote.Token

  @impl true
  def mount(%{"ballot" => token}, session, socket) do
    with {:ok, id} <- Token.verify_ballot_token(token) do
      {:ok, user} = VoteWeb.Authentication.load_user(session)
      LiveState.register(id)
      PubSub.subscribe(Vote.PubSub, "ballot/#{id}/update")
      ballot = Ballots.by_id(id)

      socket
      |> assign(ballot: ballot)
      |> assign(user: user)
      |> assign(page_title: ballot.title)
      |> update_cs(%{})
      |> ok()
    else
      _ -> socket
      |> put_flash(:error, "Invalid ballot link.")
      |> redirect(to: Routes.homepage_path(socket, :index))
      |> ok()
    end
  end

  @impl true
  def handle_event("vote", %{"response_set" => params}, socket) do
    socket
    |> update_cs(params)
    |> save_cs()
    |> noreply()
  end

  @impl true
  def handle_event("add_option", %{"option" => option, "idx" => idx}, socket) do
    idx = String.to_integer(idx)
    item_id = Enum.at(socket.assigns.ballot.ballot_items, idx).id
    option = String.trim(option)

    socket
    |> broadcast_listener({:add_option, item_id, option})
    |> noreply()
  end

  @impl true
  def handle_info({:update_item, _item_id}, socket) do
    socket
    |> assign(ballot: Ballots.by_id(socket.assigns.ballot.id))
    |> noreply()
  end

  def update_cs(socket, params) do
    # update to new ballot in case it was changed
    ballot = Ballots.by_id(socket.assigns.ballot.id)
    # get the current user from the socket
    user = socket.assigns.user
    # get the yet-to-be edited response set
    response_set = ResponseSet.find(user.id, ballot.id)
    # make a new change set from these
    assign(socket, cs: ResponseSet.changeset(response_set, params, ballot, user))
  end

  def save_cs(socket) do
    ResponseSet.save(socket.assigns.cs)
    id = socket.assigns.ballot.id
    PubSub.broadcast(Vote.PubSub, "ballot/#{id}/vote", :ballot_vote)
    socket
  end

  def broadcast_listener(socket, data) do
    id = socket.assigns.ballot.id
    PubSub.broadcast(Vote.PubSub, "ballot/#{id}/listener", data)
    socket
  end

  def voting_input(method, form, field, options, opts) do
    Voting.input(method, form, field, options, opts)
  end
end
