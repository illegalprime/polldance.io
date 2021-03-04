defmodule VoteWeb.AuthView do
  use VoteWeb, :view
  alias VoteWeb.HomepageView

  def render("index.html", assigns) do
    HomepageView.render("index.html", assigns)
  end
end
