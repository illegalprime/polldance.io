defmodule Vote.Ballots do
  import Ecto.Changeset
  import Ecto.Query
  alias Vote.Repo
  alias __MODULE__.{Ballot, BallotItem}

  def authored_by_user(user) do
    query = from b in Ballot,
      where: b.account_id == ^user.id,
      select: b,
      order_by: [desc: b.inserted_at]

    Repo.all(query)
  end

  def by_slug(slug) do
    query = from b in Ballot,
      where: b.slug == ^slug,
      select: b,
      preload: [
        ballot_items: ^from(
          item in BallotItem,
          order_by: [asc: item.id]
        )
      ]
    Repo.one(query)
  end

  def save(from, params, user, draft? \\ true) do
    build_ballot(from, params)
    |> put_assoc(:account, user)
    |> put_change(:draft, draft?)
    |> Ballot.update_slug()
    |> Repo.insert_or_update()
  end

  def publish(ballot) do
    ballot
    |> Ballot.changeset(%{})
    |> put_change(:draft, false)
    |> Repo.update()
  end

  def close(ballot) do
    ballot
    |> change(closed: true)
    |> change(live: true)
    |> Repo.update()
  end

  def new(from, params \\ %{})

  def new(nil, %{"ballot_items" => _} = params) do
    build_ballot(nil, params) |> Map.put(:action, :insert)
  end

  def new(nil, params) do
    build_ballot(nil, params) |> push_item() |> Map.put(:action, :insert)
  end

  def new(from, params) do
    build_ballot(from, params) |> Map.put(:action, :update)
  end

  def assign_quick_status(%{"ballot_items" => items} = params) do
    # make sure to correctly set the quick? attribute on ballot items
    ballot_items =
      case Map.to_list(items) do
        [] -> %{}
        [{k, v}] -> %{ items | k => Map.put(v, "quick?", true) }
        many ->
          many
          |> Enum.map(fn {k, v}  -> {k, Map.put(v, "quick?", false)} end)
          |> Map.new()
      end
    %{ params | "ballot_items" => ballot_items }
  end
  def assign_quick_status(params), do: params

  def build_ballot(from, params \\ %{})
  def build_ballot(nil, params), do: build_ballot(%Ballot{}, params)
  def build_ballot(from, params) do
    params = params |> assign_quick_status()
    from
    |> Repo.preload([:ballot_items, :account])
    |> Ballot.changeset(params)
  end

  def new_item(params) do
    %BallotItem{}
    |> BallotItem.changeset(params)
  end

  def get_items(cs) do
    get_field(cs, :ballot_items)
    |> Enum.map(fn i -> BallotItem.changeset(i, %{}) end)
  end

  def push_item(cs, params \\ %{}) do
    put_assoc(cs, :ballot_items, get_items(cs) ++ [new_item(params)])
  end

  def delete_item(cs, idx) do
    put_assoc(cs, :ballot_items, List.delete_at(get_items(cs), idx))
  end

  def get_options(%Ecto.Changeset{} = cs), do: get_field(cs, :options)
  def get_options(item), do: Map.get(item, :options)

  def delete_option(cs, item_i, option_i) do
    items = get_items(cs)
    |> Enum.with_index()
    |> Enum.map(fn {item, i} ->
      case i == item_i do
        false -> item
        true ->
          new_options = List.delete_at(get_options(item), option_i)
          put_change(item, :options, new_options)
      end
    end)
    put_assoc(cs, :ballot_items, items)
  end

  def delete(ballot) do
    ballot
    |> Repo.preload([:ballot_items])
    |> Repo.delete()
  end
end
