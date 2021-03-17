defmodule VoteWeb.BallotLive do
  use VoteWeb, :live_view
  alias Phoenix.PubSub
  alias Vote.Ballots
  alias Vote.Ballots.LiveState
  alias Vote.Ballots.ResponseSet
  alias Vote.Voting

  def load_ballot(socket, nil) do
    socket
    |> put_flash(:error, "Invalid ballot link.")
    |> redirect(to: Routes.homepage_path(socket, :index))
  end

  def load_ballot(socket, ballot) do
    LiveState.register(ballot.id)
    PubSub.subscribe(Vote.PubSub, "ballot/#{ballot.id}/update")
    socket
    |> assign(ballot: ballot)
    |> assign(page_title: ballot.title)
    |> update_cs(%{})
  end

  @impl true
  def mount(%{"ballot" => slug} = params, session, socket) do
    {:ok, user} = VoteWeb.Authentication.load_user(session)
    socket
    |> assign(user: user)
    |> load_ballot(Ballots.by_slug(slug))
    |> ok()
  end

  @impl true
  def handle_event("vote", %{"response_set" => params}, socket) do
    socket
    |> update_cs(params)
    |> save_cs()
    |> noreply()
  end

  @impl true
  def handle_event("publish_ballot", _params, socket) do
    if socket.assigns.user.id == socket.assigns.ballot.account_id do
      {:ok, ballot} = Ballots.publish(socket.assigns.ballot)
      socket
      |> put_flash(:info, "Ballot published successfully!")
      |> redirect(to: Routes.ballot_path(socket, :index, ballot.slug))
      |> noreply()
    else
      noreply(socket)
    end
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
    |> assign(ballot: Ballots.by_slug(socket.assigns.ballot.slug))
    |> noreply()
  end

  def update_cs(socket, params) do
    # update to new ballot in case it was changed
    ballot = Ballots.by_slug(socket.assigns.ballot.slug)
    # get the current user from the socket
    user = socket.assigns.user
    # get the yet-to-be edited response set
    response_set = ResponseSet.find(user.id, ballot.id)
    # make a new change set from these
    assign(socket, cs: ResponseSet.changeset(response_set, params, ballot, user))
  end

  def save_cs(socket) do
    if !socket.assigns.ballot.draft do
      ResponseSet.save(socket.assigns.cs)
      id = socket.assigns.ballot.id
      PubSub.broadcast(Vote.PubSub, "ballot/#{id}/vote", :ballot_vote)
    end
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
