defmodule VoteWeb.ResultsLive do
  use VoteWeb, :live_view
  alias Phoenix.PubSub
  alias Vote.Token
  alias Vote.Voting
  alias Vote.Ballots
  alias Vote.Ballots.ResponseSet

  @impl true
  def mount(%{"ballot" => token}, _session, socket) do
    with {:ok, id} <- Token.verify_ballot_token(token) do
      PubSub.subscribe(Vote.PubSub, "ballot/#{id}/vote")
      PubSub.subscribe(Vote.PubSub, "ballot/#{id}/update")

      socket
      |> assign(ballot: Ballots.by_id(id))
      |> assign(page_title: "Results")
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

  @impl true
  def handle_info({:update_item, _item_id}, socket) do
    socket
    |> update_ballot()
    |> noreply()
  end

  def update_ballot(socket) do
    assign(socket, ballot: Ballots.by_id(socket.assigns.ballot.id))
  end

  def update_responses(socket) do
    id = socket.assigns.ballot.id
    assign(socket, responses: group(ResponseSet.find_results(id)))
  end

  def group(responses) do
    Enum.group_by(responses, fn r -> r.ballot_item_id end)
  end

  def display_many(results) do
    results
    |> Enum.slice(0..-2)
    |> Enum.join(", ")
    |> (fn commas -> if commas == "", do: [], else: [commas] end).()
    |> Enum.concat([Enum.at(results, -1)])
    |> Enum.join(" & ")
  end

  def add_ranks(results) do
    Enum.reduce(results, {0, nil, []}, fn {opt, score}, {rank, last, out} ->
      cond do
        last != score -> {rank + 1, score, [{opt, score, rank + 1} | out]}
        last == score -> {rank, score, [{opt, score, rank} | out]}
      end
    end)
    |> elem(2)
    |> Enum.reverse()
  end

  def tally(method, responses, options) do
    votes = Enum.map(responses, &(&1.response))
    Voting.tally(method, votes, options)
  end
end
