defmodule Vote.Voting do
  alias VoteWeb.Views.InputHelpers.RankingInput
  alias VoteWeb.Views.InputHelpers.RatingInput
  alias VoteWeb.Views.InputHelpers.ApprovalInput
  alias VoteWeb.Views.InputHelpers.SelectOneInput

  alias Vote.Voting.Approval
  alias Vote.Voting.RankedChoice
  alias Vote.Voting.Star

  def methods() do
    %{
      "Approval" => "approval",
      # "Borda" => "borda",
      # "Borda (Naura)" => "nauru",
      # "Condorcet" => "condorcet",
      "Majority / Plurality" => "plurality",
      "Ranked Choice" => "rank_choice",
      # "Schulze" => "schulze",
      "STAR" => "star",
    }
  end

  def input(method, form, field, options, opts) do
    fns = %{
      "plurality"   => {&SelectOneInput.select_one_input/4, []},
      "approval"    => {&ApprovalInput.approval_input/4, []},
      "star"        => {&RatingInput.rating_input/4, [n: 5]},
      "rank_choice" => {&RankingInput.ranking_input/4, []},
      "borda"       => {&RankingInput.ranking_input/4, []},
      "nauru"       => {&RankingInput.ranking_input/4, []},
      "schulze"     => {&RankingInput.ranking_input/4, []},
      "condorcet"   => {&RankingInput.ranking_input/4, []},
    }
    {input, base_opts} = fns[method]
    input.(form, field, options, base_opts ++ opts)
  end

  def tally(method, votes, options) do
    opt_idxs = if Enum.empty?(options) do
      []
    else
      0..length(options) - 1
      |> Enum.map(&Integer.to_string/1)
    end

    fns = %{
      "plurality"   => &Approval.tally/2,
      "approval"    => &Approval.tally/2,
      "star"        => &Star.tally/2,
      "rank_choice" => &RankedChoice.tally/2,
      # "borda"       => &Approval.tally/2,
      # "nauru"       => &Approval.tally/2,
      # "schulze"     => &Approval.tally/2,
      # "condorcet"   => &Approval.tally/2,
    }
    {winner, results} = fns[method].(votes, opt_idxs)
    {idxs_to_opts(winner, options), idxs_to_opts(results, options)}
  end

  def render(method, vote, options) do
    fns = %{
      "plurality"   => &Approval.render/1,
      "approval"    => &Approval.render/1,
      "star"        => &Star.render/1,
      "rank_choice" => &RankedChoice.render/1,
    }
    fns[method].(vote) |> idxs_to_opts(options)
  end

  def rank_order(vote) do
    vote
    |> Enum.sort_by(fn {_, v} -> v end)
    |> Enum.take_while(fn {k, _} -> k != "-1" end)
    |> Enum.map(fn {k, _} -> k end)
  end

  def winner_is_first([], _), do: {[], []}
  def winner_is_first([{_, floor} | _] = results, floor) do
    {[], results}
  end
  def winner_is_first([{_, score} | _] = results, _floor) do
    {Enum.take_while(results, fn {_, s} -> s == score end), results}
  end

  def idxs_to_opts(results, options) do
    Enum.map(results, fn {i, score} ->
      {Enum.at(options, String.to_integer(i)), score}
    end)
  end

  def add_missing_opts(count, options, default) do
    Enum.reduce(options, count, fn opt, running ->
      case Map.get(running, opt) do
        nil -> Map.put(running, opt, default)
        _el -> running
      end
    end)
  end
end
