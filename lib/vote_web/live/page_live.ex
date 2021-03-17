defmodule VoteWeb.PageLive do
  use VoteWeb, :live_view
  alias Phoenix.PubSub
  alias VoteWeb.Authentication
  alias Vote.Ballots
  alias Vote.Ballots.ResponseSet

  @impl true
  def mount(_params, session, socket) do
    {:ok, user} = Authentication.load_user(session)

    socket
    |> assign(account: user)
    |> assign(page_title: "Home")
    |> update(user)
    |> ok()
  end

  def handle_event("delete_modal", %{"idx" => idx}, socket) do
    params = %{
      title: "Delete Ballot?",
      desc: :delete,
      ok_click: "delete",
      ok_data: idx,
    }
    socket
    |> assign(modal: params)
    |> noreply()
  end

  def handle_event("close_modal", _params, socket) do
    socket
    |> assign(modal: nil)
    |> noreply()
  end

  def handle_event("delete", %{"data" => idx}, socket) do
    {:ok, ballot} = socket.assigns.my_ballots
    |> Enum.at(String.to_integer(idx))
    |> Ballots.delete()

    topic = "ballot/#{ballot.id}/update"
    PubSub.broadcast(Vote.PubSub, topic, :ballot_deleted)

    socket
    |> update(socket.assigns.account)
    |> assign(modal: nil)
    |> noreply()
  end

  def update(socket, user) do
    socket
    |> assign(my_ballots: Ballots.authored_by_user(user))
    |> assign(voted_ballots: ResponseSet.find_ballots(user.id))
  end
end
