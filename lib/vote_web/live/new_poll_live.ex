defmodule VoteWeb.NewPollLive do
  use VoteWeb, :live_view
  alias Vote.Ballots
  alias Vote.Voting
  alias Ecto.Changeset

  @impl true
  def mount(_params, session, socket) do
    {:ok, user} = VoteWeb.Authentication.load_user(session)
    socket
    |> assign(cs: Ballots.new())
    |> assign(page_title: "New Ballot")
    |> assign(account: user)
    |> ok()
  end

  @impl true
  def handle_event("validate", %{"ballot" => ballot}, socket) do
    socket
    |> assign(cs: Ballots.new(ballot))
    |> noreply()
  end

  @impl true
  def handle_event("save", %{"ballot" => ballot}, socket) do
    case Ballots.save(ballot, socket.assigns.account) do
      {:error, %Ecto.Changeset{} = cs} ->
        socket
        |> assign(cs: cs)
        |> noreply()

      {:ok, ballot} ->
        socket
        |> put_flash(:info, "Published successfully!")
        |> push_redirect(to: Routes.ballot_url(socket, :index, ballot.slug))
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

  def handle_event("push_option", %{"idx" => idx}, socket) do
    socket
    |> assign(cs: Ballots.push_option(socket.assigns.cs, String.to_integer(idx)))
    |> noreply()
  end

  def handle_event("delete_option", %{"idx" => idx, "item" => item}, socket) do
    idx = String.to_integer(idx)
    item = String.to_integer(item)

    socket
    |> assign(cs: Ballots.delete_option(socket.assigns.cs, item, idx))
    |> noreply()
  end

  def voting_methods(), do: Voting.methods
end
