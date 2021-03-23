defmodule Vote.Voting.Star do
  alias Vote.Voting.Approval

  def tally(_votes, []), do: {[], []}
  def tally(votes, [option]), do: Approval.tally(votes, [option])
  def tally(votes, options) do
    # first sum every vote score to get the highest total
    Approval.tally(votes, options)
    # this returns a tuple of winner and results, get results
    |> elem(1)
    # take at least two of the highest scoring candidates and do a runoff
    |> do_runoff(votes)
    # combine old and new results for detailed report
    |> combine()
  end

  def do_runoff([], _), do: {%{}, [], []}
  def do_runoff([{o, _}] = results, _), do: {%{o => 1}, results, []}
  def do_runoff([{_, score} | _] = results, votes) do
    # get at least two with the highest score for runoff
    [opts, loser_opts] = results
    |> Enum.with_index()
    |> Enum.chunk_by(fn {{_, s}, i} -> i < 2 or s == score end)
    |> Enum.map(fn l -> Enum.map(l, fn {el, _} -> el end) end)
    # zero each option to prep for counting votes
    ballot = opts |> Enum.map(fn {o, _} -> {o, 0} end) |> Map.new()
    # count number of wins in a head-to-head
    scores = Enum.reduce(votes, ballot, fn vote, counter ->
      {winner, _} = vote
      |> Enum.sort_by(fn {_, v} -> -v end)
      |> Enum.find(fn {k, _} -> Map.has_key?(counter, k) end)
      %{ counter | winner => counter[winner] + 1 }
    end)
    {scores, opts, loser_opts}
  end

  def combine({runoff_results, runoff_opts, other_opts}) do
    # sort the runoff results and add them to existing results
    results = runoff_opts
    |> Enum.sort_by(fn {k, _} -> -runoff_results[k] end)
    |> Enum.concat(other_opts)
    |> Enum.map(fn {opt, score} -> {opt, [score, runoff_results[opt]]} end)
    # find the winning score and build a winner list
    {_, win_score} = Enum.max_by(runoff_results, fn {_, v} -> v end)
    winners = Enum.filter(results, fn {_, [_, v]} -> v == win_score end)
    # return a standard winner / results pair
    {winners, results}
  end

  def render(vote) do
    Enum.sort_by(vote, fn {_, v} -> -v end)
  end
end
