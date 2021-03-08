defmodule VoteWeb.PageLive do
  use VoteWeb, :live_view
  alias VoteWeb.Authentication
  alias Vote.Ballots
  alias Vote.Token

  def ok(socket), do: {:ok, socket}
  def noreply(socket), do: {:noreply, socket}

  @impl true
  def mount(_params, session, socket) do
    {:ok, user} = Authentication.load_user(session)
    ballots = Ballots.authored_by_user(user)

    socket
    |> assign(account: user)
    |> assign(page_title: "Home")
    |> assign(my_ballots: ballots.authored_ballots)
    |> ok()
  end

  # TODO: don't generate new tokens on every page load?
  def ballot_link(socket, ballot) do
    token = Token.gen_ballot_token(ballot)
    Routes.ballot_url(socket, :index, token)
  end
end
