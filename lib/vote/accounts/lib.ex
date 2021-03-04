defmodule Vote.Accounts do
  alias Vote.Repo
  alias __MODULE__.Account

  def by_id(id), do: Repo.get(Account, id)

  def by_email(email), do: Repo.get_by(Account, email: email)

  def register(%Ueberauth.Auth{provider: :identity} = params) do
    %Account{}
    |> Account.unverified_changeset(extract_account_params(params))
    |> Repo.insert()
  end

  def register(%Ueberauth.Auth{} = params) do
    %Account{}
    |> Account.oauth_changeset(extract_account_params(params))
    |> Repo.insert()
  end

  def get_or_register(%Ueberauth.Auth{info: %{email: email}} = params) do
    case by_email(email) do
      nil -> register(params)
      account -> {:ok, account}
    end
  end

  def extract_account_params(
    %{credentials: %{other: other}, info: info, provider: provider}
  ) do
    info
    |> Map.from_struct()
    |> Map.merge(other)
    |> Map.put(:provider, to_string(provider))
  end

  def mark_verified(id) do
    with account <- by_id(id),
         %Account{verified: false} <- account
      do
      account
      |> Account.verified_changeset()
      |> Repo.update()
    else
      _ -> {:error, :already_verified}
    end
  end
end
