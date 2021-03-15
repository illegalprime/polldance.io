defmodule Vote.Ballots.ResponseSet do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias __MODULE__
  alias Ecto.Multi
  alias Vote.Repo
  alias Vote.Ballots.BallotItem
  alias Vote.Ballots.Responses

  embedded_schema do
    embeds_many :responses, Vote.Ballots.Responses
  end

  def find(account_id, ballot_id) do
    query = from r in Vote.Ballots.Responses,
      where: r.ballot_id == ^ballot_id and r.account_id == ^account_id

    %ResponseSet{
      responses: Repo.all(query),
    }
  end

  def find_ballots(account_id) do
    query = from r in Vote.Ballots.Responses,
      join: ballot in Vote.Ballots.Ballot,
      on: ballot.id == r.ballot_id,
      where: r.account_id == ^account_id,
      order_by: [desc: ballot.inserted_at],
      select: ballot,
      distinct: true

    Repo.all(query)
  end

  def find_results(ballot_id) do
    query = from r in Vote.Ballots.Responses,
      where: r.ballot_id == ^ballot_id

    Repo.all(query)
    |> Repo.preload(:account)
  end

  def save(cs) do
    cs
    |> get_change(:responses)
    |> Enum.with_index()
    |> Enum.reduce(Multi.new(), fn {response, i}, multi ->
      Multi.insert_or_update(multi, Integer.to_string(i), response)
    end)
    |> Repo.transaction()
  end

  def changeset(response_set, attrs, ballot, account) do
    changesets = ballot.ballot_items
    |> Enum.with_index()
    |> Enum.map(fn {bitem, idx} ->
      params = get_responses(attrs["responses"], idx)

      response_set.responses
      |> Enum.find(%Responses{}, &(&1.ballot_item_id == bitem.id))
      |> Responses.changeset(params, account.id, ballot.id, bitem)
    end)

    response_set
    |> change()
    |> put_embed(:responses, changesets)
  end

  def get_responses(nil, _idx), do: %{}
  def get_responses(params, idx) do
    convert_responses(Map.get(params, "#{idx}"))
  end

  def convert_responses(nil), do: %{}
  def convert_responses(%{"response" => items} = params) when is_list(items) do
    items
    |> Enum.with_index()
    |> Map.new()
    |> (fn r -> %{ params | "response" => r } end).()
  end
  def convert_responses(%{"response" => items} = params) when is_map(items) do
    items
    |> Map.to_list()
    |> Enum.map(fn {k, v} -> {k, to_int(v)} end)
    |> Map.new()
    |> (fn r -> %{ params | "response" => r } end).()
  end
  def convert_responses(%{"response" => "-1"} = params) do
    %{ params | "response" => %{} }
  end
  def convert_responses(%{"response" => item} = params) when is_binary(item) do
    %{ params | "response" => %{item => 1} }
  end
  def convert_responses(other), do: other

  def to_int("true"), do: 1
  def to_int("false"), do: 0
  def to_int(str) when is_binary(str), do: String.to_integer(str)
end
