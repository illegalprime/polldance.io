defmodule VoteWeb.Authentication.ErrorHandler do
  require Logger
  use VoteWeb, :controller

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, error, _opts) do
    conn
    |> put_session(:login_redirect, current_path(conn))
    |> put_flash(:error, "Authentication Error.")
    |> redirect(to: Routes.homepage_path(conn, :index))
  end
end
