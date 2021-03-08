defmodule Vote.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset

  # Created With:
  # mix phx.gen.schema Accounts.Account accounts \
  #   email:string encrypted_password:string verified:boolean provider:string
  schema "accounts" do
    field :email, :string
    field :password, :string, virtual: true
    field :encrypted_password, :string
    field :provider, :string
    field :verified, :boolean, default: false
    many_to_many :ballots, Vote.Ballots.Ballot, join_through: "ballots_accounts"
    has_many :authored_ballots, Vote.Ballots.Ballot

    timestamps()
  end

  def unverified_changeset(account, attrs) do
    account
    |> cast(attrs, [:email, :password, :provider])
    |> validate_required([:email, :password, :provider])
    |> validate_confirmation(:password, required: true)
    |> unique_constraint(:email)
    |> put_encrypted_password()
  end

  def verified_changeset(account) do
    account
    |> change
    |> put_change(:verified, true)
  end

  def oauth_changeset(account, attrs) do
    account
    |> cast(attrs, [:email, :provider])
    |> validate_required([:email, :provider])
    |> put_change(:verified, true)
    |> unique_constraint(:email)
  end

  defp put_encrypted_password(%{valid?: true, changes: %{password: pw}} = cs) do
    put_change(cs, :encrypted_password, Argon2.hash_pwd_salt(pw))
  end
  defp put_encrypted_password(changeset), do: changeset
end
