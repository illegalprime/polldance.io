defmodule Vote.Voting.Approval do
  alias Vote.Voting

  def tally(votes, options) do
    votes
    |> Enum.reduce(%{}, &sum_single_vote/2)
    |> Voting.add_missing_opts(options, 0)
    |> Enum.sort_by(fn {_, v} -> -v end)
    |> Voting.winner_is_first(0)
  end

  def sum_single_vote(vote, totals) do
    Enum.reduce(vote, totals, fn {option, value}, sum ->
      Map.put(sum, option, Map.get(sum, option, 0) + value)
    end)
  end
end
