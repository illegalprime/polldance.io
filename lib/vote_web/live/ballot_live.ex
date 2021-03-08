defmodule VoteWeb.BallotLive do
  use VoteWeb, :live_view
  alias Vote.Ballots
  alias Vote.Token

  def ok(socket), do: {:ok, socket}
  def noreply(socket), do: {:noreply, socket}

  @impl true
  def mount(%{"ballot" => token}, _session, socket) do
    with {:ok, id} <- Token.verify_ballot_token(token) do
      ballot = Ballots.by_id(id)
      socket
      |> assign(ballot: ballot)
      |> assign(page_title: ballot.title)
      |> ok()
    else
      _ -> socket
      |> put_flash(:error, "Invalid or expired (100 days) ballot link.")
      |> redirect(to: Routes.homepage_path(socket, :index))
      |> ok()
    end
  end
end
