defmodule VoteWeb.ResultsLive do
  use VoteWeb, :live_view
  alias Phoenix.PubSub
  alias Vote.Voting
  alias Vote.Ballots
  alias Vote.Ballots.ResponseSet

  def load_ballot(socket, nil) do
    socket
    |> put_flash(:error, "Invalid ballot link.")
    |> redirect(to: Routes.homepage_path(socket, :index))
  end

  def load_ballot(socket, ballot) do
    PubSub.subscribe(Vote.PubSub, "ballot/#{ballot.id}/vote")
    PubSub.subscribe(Vote.PubSub, "ballot/#{ballot.id}/update")
    socket
    |> assign(ballot: ballot)
    |> assign(page_title: "Results")
    |> update_responses()
  end

  @impl true
  def mount(%{"ballot" => slug}, session, socket) do
    ballot = Ballots.by_slug(slug)
    account = VoteWeb.Authentication.load_user(session)

    case {account, ballot} do
      {{:ok, _user}, _} ->
        socket
        |> load_ballot(ballot)
        |> ok()
      {{:error, _}, %Ballots.Ballot{public: true}} ->
        socket
        |> load_ballot(ballot)
        |> ok()
      {{:error, _}, _} ->
        curr_path = Routes.results_path(socket, :index, slug)
        socket
        |> put_flash(:error, "Authentication Error.")
        |> redirect(to: Routes.homepage_path(socket, :index, cb: curr_path))
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
  def handle_info(:ballot_updated, socket) do
    socket
    |> update_ballot()
    |> noreply()
  end

  @impl true
  def handle_info(:ballot_deleted, socket) do
    socket
    |> put_flash(:error, "Ballot was deleted.")
    |> redirect(to: Routes.homepage_path(socket, :index))
    |> noreply()
  end

  def update_ballot(socket) do
    assign(socket, ballot: Ballots.by_slug(socket.assigns.ballot.slug))
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
    votes = Enum.map(responses || [], &(&1.response))
    Voting.tally(method, votes, options)
  end

  def render_vote(method, response, options) do
    Voting.render(method, response, options)
  end

  def max_rounds(results) do
    results
    |> Enum.map(fn {_opt, score} ->
      case score do
        [_ | _] -> length(score)
        _ -> 1
      end
    end)
    |> Enum.max()
  end
end
