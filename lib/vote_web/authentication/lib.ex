defmodule VoteWeb.Authentication do
  use Guardian, otp_app: :vote
  alias Vote.{Accounts, Accounts.Account}

  @claims %{"typ" => "access"}
  @token_key "guardian_default_token"

  def subject_for_token(resource, _claims) do
    {:ok, to_string(resource.id)}
  end

  def resource_from_claims(%{"sub" => id}) do
    case Accounts.by_id(id) do
      nil -> {:error, :resource_not_found}
      account -> {:ok, account}
    end
  end

  def log_in(conn, account) do
    __MODULE__.Plug.sign_in(conn, account)
  end

  def get_current_account(conn) do
    __MODULE__.Plug.current_resource(conn)
  end

  def load_user(%{@token_key => token}) do
    case Guardian.decode_and_verify(__MODULE__, token, @claims) do
      {:ok, claims} -> resource_from_claims(claims)
      _ -> {:error, :not_authorized}
    end
  end

  def authenticate(%Account{verified: false}, _) do
    {:error, :not_verified}
  end

  def authenticate(%Account{} = account, password) do
    authenticate(
      account,
      password,
      Argon2.verify_pass(password, account.encrypted_password)
    )
  end

  def authenticate(nil, password) do
    authenticate(nil, password, Argon2.no_user_verify())
  end

  defp authenticate(account, _password, true) do
    {:ok, account}
  end

  defp authenticate(_account, _password, false) do
    {:error, :invalid_credentials}
  end

  def log_out(conn) do
    __MODULE__.Plug.sign_out(conn)
  end
end
