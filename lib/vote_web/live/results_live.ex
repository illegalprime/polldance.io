defmodule VoteWeb.ResultsLive do
  use VoteWeb, :live_view
  alias Vote.Token
  alias Phoenix.PubSub
  alias Vote.Ballots.ResponseSet

  @impl true
  def mount(%{"ballot" => token}, _session, socket) do
    with {:ok, id} <- Token.verify_ballot_token(token) do
      PubSub.subscribe(Vote.PubSub, "ballot/#{id}/vote")

      socket
      |> assign(ballot_id: id)
      |> update_responses()
      |> ok()
    else
      _ -> socket
      |> put_flash(:error, "Invalid ballot link.")
      |> redirect(to: Routes.homepage_path(socket, :index))
      |> ok()
    end
  end

  @impl true
  def handle_info(:ballot_vote, socket) do
    socket
    |> update_responses()
    |> noreply()
  end

  def update_responses(socket) do
    id = socket.assigns.ballot_id
    assign(socket, responses: group(ResponseSet.find_results(id)))
  end

  def group(responses) do
    responses
    |> Enum.group_by(fn r -> r.ballot_item_id end)
    |> Map.values()
  end
end
