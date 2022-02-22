defmodule VoteWeb.NewPollLive do
  import Ecto.Changeset
  use VoteWeb, :live_view
  alias Phoenix.PubSub
  alias Vote.Ballots
  alias Vote.Voting

  # TODO: when someone is redirected to the ballot view after saving
  # and then wants to edit, they go back in history to the /new page
  # make it so they instead go back and edit the ballot in /edit/:id

  @impl true
  def mount(%{"ballot" => slug}, session, socket) do
    {:ok, user} = VoteWeb.Authentication.load_user(session)
    ballot = Ballots.by_slug(slug)

    cond do
      is_nil(ballot) ->
        socket
        |> put_flash(:error, "Invalid ballot link.")
        |> redirect(to: Routes.homepage_path(socket, :index))
        |> ok()

      ballot.account_id != user.id ->
        socket
        |> put_flash(:error, "Only ballot authors can edit their ballot.")
        |> redirect(to: Routes.homepage_path(socket, :index))
        |> ok()

      true ->
        PubSub.subscribe(Vote.PubSub, "ballot/#{ballot.id}/update")

        socket
        |> assign(ballot: ballot)
        |> update_ballot()
        |> assign(page_title: "Edit " <> ballot.title)
        |> assign(account: user)
        |> ok()
    end
  end

  @impl true
  def mount(_params, session, socket) do
    {:ok, user} = VoteWeb.Authentication.load_user(session)
    socket
    |> assign(ballot: nil)
    |> update_ballot()
    |> assign(page_title: "New Ballot")
    |> assign(account: user)
    |> ok()
  end

  @impl true
  def handle_info(:ballot_updated, socket) do
    socket
    |> update_ballot()
    |> noreply()
  end

  @impl true
  def handle_info(:ballot_closed, socket) do
    slug = socket.assigns.ballot.slug
    socket
    |> put_flash(:error, "Ballot was closed.")
    |> redirect(to: Routes.results_path(socket, :index, slug))
    |> noreply()
  end

  @impl true
  def handle_info(:ballot_deleted, socket) do
    socket
    |> put_flash(:error, "Ballot was deleted.")
    |> redirect(to: Routes.homepage_path(socket, :index))
    |> noreply()
  end

  @impl true
  def handle_event("validate", %{"ballot" => ballot}, socket) do
    socket
    |> update_ballot(ballot)
    |> noreply()
  end

  @impl true
  def handle_event("save", %{"ballot" => params}, socket) do
    case Ballots.save(socket.assigns.ballot, params, socket.assigns.account) do
      {:error, %Ecto.Changeset{} = cs} ->
        socket
        |> assign(cs: cs)
        |> noreply()

      {:ok, ballot} ->
        socket
        |> put_flash(:info, "Draft saved successfully!")
        |> push_redirect(to: Routes.ballot_path(socket, :index, ballot.slug))
        |> noreply()
    end
  end

  @impl true
  def handle_event("push_ballot_item", _, socket) do
    socket
    |> assign(cs: Ballots.push_item(socket.assigns.cs))
    |> noreply()
  end

  def handle_event("delete_ballot_item", %{"idx" => idx}, socket) do
    socket
    |> assign(cs: Ballots.delete_item(socket.assigns.cs, String.to_integer(idx)))
    |> noreply()
  end

  def handle_event("delete_option", %{"idx" => idx, "item" => item}, socket) do
    idx = String.to_integer(idx)
    item = String.to_integer(item)

    socket
    |> assign(cs: Ballots.delete_option(socket.assigns.cs, item, idx))
    |> noreply()
  end

  def update_ballot(socket, params \\ %{}) do
    assign(socket, cs: Ballots.new(socket.assigns.ballot, params))
  end

  def data_or_cs(%Ecto.Changeset{} = cs, key), do: get_field(cs, key)
  def data_or_cs(data, key), do: Map.get(data, key)

  def voting_methods(), do: Voting.methods
end
