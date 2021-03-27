defmodule VoteWeb.HomepageController do
  alias Vote.Accounts.Account
  use VoteWeb, :controller

  @memes [
    "/images/bidenist.png",
    "/images/shapiro.jpg",
    "/images/bunny.jpg",
    "/images/liberal.jpg",
    "/images/llama.jpg",
    "/images/racoon.png",
  ]

  @account_cs Account.unverified_changeset(%Account{}, %{})

  def index(conn, params) do
    if conn.assigns[:account] do
      redirect(conn, to: Routes.page_path(conn, :index))
    else
      splash = Routes.static_path(conn, Enum.random(@memes))
      conn
      |> put_login_redir(params)
      |> render(:index,
        splash: splash,
        page_title: "Login",
        login: Routes.auth_path(conn, :login),
        login_cs: Map.get(conn.assigns, :login_cs, @account_cs),
        register: Routes.auth_path(conn, :register),
        register_cs: Map.get(conn.assigns, :register_cs, @account_cs)
      )
    end
  end

  def put_login_redir(conn, %{"cb" => path}) do
    put_session(conn, :login_redirect, path)
  end
  def put_login_redir(conn, _params), do: conn
end
