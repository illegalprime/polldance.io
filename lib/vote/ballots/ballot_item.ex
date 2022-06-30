defmodule Vote.Ballots.BallotItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ballot_items" do
    field :appendable, :boolean, default: false
    field :comments, :boolean, default: false
    field :desc, :string
    field :options, {:array, :string}
    field :title, :string
    field :voting_method, :string
    belongs_to :ballot, Vote.Ballots.Ballot

    timestamps()
  end

  @doc false
  def changeset(ballot_item, attrs) do
    ballot_item
    |> cast(attrs, [:title, :desc, :voting_method, :appendable])
    |> put_options(Map.get(attrs, "options") || attrs[:options])
    |> validate_required([:options, :voting_method, :appendable])
    |> quick_validations(Map.get(attrs, "quick?", false))
    |> unique_constraint(:title)
  end

  def quick_validations(cs, true), do: cs
  def quick_validations(cs, false) do
    validate_required(cs, [:title])
  end

  def push_option_cs(ballot_item, option) do
    valid? = option_valid(ballot_item.options, option)
    append? = ballot_item.appendable

    ballot_item
    |> change()
    |> put_change(:options, ballot_item.options ++ [option])
    |> do_if(!valid? or !append?, &(add_error(&1, :options, "bad new option")))
  end

  def option_valid(options, option) do
    option = option |> String.downcase() |> String.trim()
    size? = String.length(option) > 0
    dup? = options
    |> Enum.map(&String.downcase/1)
    |> Enum.map(&String.trim/1)
    |> Enum.any?(fn o -> o == option end)

    size? && !dup?
  end

  defp put_options(cs, nil), do: cs
  defp put_options(cs, options) do
    # remove any leading empty options (based on array_input implementation)
    options = options
    |> Enum.reverse()
    |> Enum.map(&String.trim/1)
    |> Enum.drop_while(&bad_option_value/1)
    |> Enum.reverse()

    # check if there are empty options in the middle
    empty_err = "cannot contain an empty option in the middle / at the start"
    has_empty? = Enum.any?(options, &bad_option_value/1)

    # if others can't add options then an option minimum is required
    appendable? = current_value(cs, :appendable)
    # check if there's at least two options to vote on
    len_err = "must have at least two options"
    has_two? = length(options) >= 2

    cs
    |> do_if(has_empty?, &(add_error(&1, :options, empty_err)))
    |> do_if(!appendable? && !has_two?, &(add_error(&1, :options, len_err)))
    |> put_change(:options, options)
  end

  defp bad_option_value(v), do: v == ""

  def current_value(cs, key) do
    Map.get(cs.changes, key, Map.get(cs.data, key))
  end

  def do_if(obj, pred, f) do
    case pred do
      true -> f.(obj)
      false -> obj
    end
  end
end
