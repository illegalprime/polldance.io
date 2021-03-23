defmodule Vote.Voting.Borda do
  alias Vote.Voting
  alias Vote.Voting.Approval

  def tally(votes, options) do
    n = length(options) - 1
    votes
    |> Enum.map(&Voting.rank_order/1)
    |> Enum.map(fn vote -> Enum.zip(vote, n..0) end)
    |> Approval.tally(options)
  end

  def render(vote) do
    Voting.rank_order(vote) |> Enum.map(fn o -> {o, nil} end)
  end
end
