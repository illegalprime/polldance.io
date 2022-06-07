defmodule VoteWeb.Authentication.ErrorHandler do
  use VoteWeb, :controller

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, _error, _opts) do
    conn
    |> put_session(:login_redirect, current_path(conn))
    |> put_flash(:error, "Please log in first! (Authentication Error)")
    |> redirect(to: Routes.homepage_path(conn, :index) <> "#login")
  end
end
