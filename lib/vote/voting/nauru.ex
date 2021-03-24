defmodule Vote.Voting.Nauru do
  use Ratio
  alias Vote.Voting

  def tally(votes, options) do
    scores = Enum.map(1..length(options), fn i -> 1 <|> i end)
    votes
    |> Enum.map(&Voting.rank_order/1)
    |> Enum.map(fn vote -> Enum.zip(vote, scores) end)
    |> Enum.reduce(%{}, &sum_single_vote/2)
    |> Voting.add_missing_opts(options, Ratio.new(0))
    |> Enum.sort(fn {_, a}, {_, b} -> Ratio.gte?(a, b) end)
    |> Voting.winner_is_first(Ratio.new(0))
  end

  def sum_single_vote(vote, totals) do
    Enum.reduce(vote, totals, fn {option, value}, sum ->
      Map.put(sum, option, Map.get(sum, option, 0) + value)
    end)
  end

  def render(vote) do
    Voting.rank_order(vote) |> Enum.map(fn o -> {o, nil} end)
  end
end
