defmodule VoteWeb.AuthController do
  use VoteWeb, :controller
  plug Ueberauth

  alias Vote.Accounts
  alias Vote.Token
  alias Vote.Email
  alias VoteWeb.Authentication
  alias VoteWeb.HomepageController

  def login(conn, %{"account" => %{"email" => email, "password" => pass}}) do
    case email |> Accounts.by_email() |> Authentication.authenticate(pass) do
      {:ok, account} ->
        redirect =
          case get_session(conn, :login_redirect) do
            nil -> Routes.homepage_path(conn, :index)
            val -> val
          end

        conn
        |> put_session(:login_redirect, nil)
        |> Authentication.log_in(account)
        |> redirect(to: redirect)

      {:error, :not_verified} ->
        conn
        |> put_flash(:error, "You must verify your email before logging in!")
        |> redirect(to: Routes.homepage_path(conn, :index))

      {:error, :invalid_credentials} ->
        conn
        |> put_flash(:error, "Incorrect email or password.")
        |> redirect(to: Routes.homepage_path(conn, :index))
    end
  end

  def callback(%{assigns: %{ueberauth_failure: _}} = conn, _params) do
    conn
    |> put_flash(:error, "Authentication failed.")
    |> redirect(to: Routes.homepage_path(conn, :index))
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case Accounts.get_or_register(auth) do
      {:ok, account} ->
        conn
        |> Authentication.log_in(account)
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, _error_changeset} ->
        conn
        |> put_flash(:error, "Authentication failed.")
        |> redirect(to: Routes.homepage_path(conn, :index))
    end
  end

  def logout(conn, _params) do
    conn
    |> Authentication.log_out()
    |> redirect(to: Routes.homepage_path(conn, :index))
  end

  def register(%{assigns: %{ueberauth_auth: %{provider: :identity} = auth}} = conn, _) do
    case Accounts.register(auth) do
      {:ok, account} ->
        # generate an email verification token
        token = Token.generate_new_account_token(account)
        # generate the link to send in the email, pointing to our verify route
        verification_url = Routes.auth_url(conn, :verify_email, token: token)
        # send email
        Email.send_account_verification_email(account, verification_url)
        # get the domain of their email to have a nice link on the confirm page
        domain = account.email |> String.split("@") |> List.last()
        # render the page asking a user to check their email
        render(conn, :confirm, email: account.email, domain: domain)

      {:error, changeset} ->
        conn
        |> assign(:register_cs, changeset)
        |> HomepageController.index(%{})
    end
  end

  def verify_email(conn, %{"token" => token}) do
    with {:ok, id} <- Token.verify_new_account_token(token),
         {:ok,  _} <- Accounts.mark_verified(id) do
      conn
      |> put_flash(:info, "Email successfully verified! Please log in.")
      |> redirect(to: Routes.homepage_path(conn, :index))
    else
      _ -> conn
      |> put_flash(:error, "The verification token is invalid or has already been used.")
      |> redirect(to: Routes.homepage_path(conn, :index))
    end
  end

  def verify_email(conn, _) do
    conn
    |> put_flash(:error, "No verification token found in URL.")
    |> redirect(to: Routes.homepage_path(conn, :index))
  end
end
