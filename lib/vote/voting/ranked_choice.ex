defmodule Vote.Voting.RankedChoice do
  alias Vote.Voting

  def tally(votes, options) do
    target = length(votes) / 2
    votes
    |> Enum.map(&Voting.rank_order/1)
    |> do_rounds(target, [])
    |> combine_rounds(options)
    |> Enum.sort_by(fn {_, rounds} -> -(List.last(rounds) || 0) end)
    |> Voting.winner_is_first([0], &List.last/1)
  end

  def do_rounds(votes, n, rounds) do
    round = tally_first_choice(votes)
    rounds = rounds ++ [round]

    if round == %{} do
      rounds
    else
      case Enum.min_max_by(round, fn {_, v} -> v end) do
        {_min, {_, v}} when v > n -> rounds
        {{_, v}, _max} ->
          round
          |> Enum.filter(fn {_, score} -> v == score end)
          |> Enum.map(fn {k, _} -> k end)
          |> MapSet.new()
          |> prune(votes)
          |> do_rounds(n, rounds)
      end
    end
  end

  def combine_rounds(rounds, options) do
    Enum.reduce(rounds, %{}, fn round, combined ->
      Enum.reduce(options, combined, fn opt, acc ->
        score = Map.get(round, opt, 0)
        Map.update(acc, opt, [score], fn scores -> scores ++ [score] end)
      end)
    end)
  end

  def prune(to_remove, votes) do
    votes
    |> Enum.map(fn vote ->
      Enum.reject(vote, fn o -> MapSet.member?(to_remove, o) end)
    end)
  end

  def tally_first_choice(votes) do
    votes
    |> Enum.map(&List.first/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.reduce(%{}, fn vote, acc ->
      Map.update(acc, vote, 1, &(&1 + 1))
    end)
  end

  def render(vote) do
    Voting.rank_order(vote)
    |> Enum.map(fn o -> {o, nil} end)
  end
end
