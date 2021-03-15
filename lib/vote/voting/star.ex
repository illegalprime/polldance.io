defmodule Vote.Voting.Star do
  alias Vote.Voting.Approval

  def tally(_votes, []), do: {[], []}
  def tally(votes, [option]), do: Approval.tally(votes, [option])
  def tally(votes, options) do
    # first a score round (sum)
    {_winner, results} = Approval.tally(votes, options)
    # then pick the two highest scoring and run-off
    winner = results
    |> Enum.sort_by(fn {_, v} -> -v end)
    |> Enum.slice(0..1)  # TODO: more than two tied for second?
    |> Enum.map(fn {k, _} -> k end)
    |> runoff(votes)

    {winner, results}
  end

  def runoff([a, b], votes) do
    winner = Enum.reduce(votes, 0, fn vote, acc ->
      case {Map.get(vote, a, 0), Map.get(vote, b, 0)} do
        {x, y} when x > y -> acc + 1
        {x, y} when x < y -> acc - 1
        _ -> acc
      end
    end)
    cond do
      winner > 0 -> [{a, nil}]
      winner < 0 -> [{b, nil}]
      winner == 0 -> [{a, nil}, {b, nil}]
    end
  end

  def render(vote) do
    Enum.sort_by(vote, fn {_, v} -> -v end)
  end
end
