defmodule VoteWeb.HomepageView do
  use VoteWeb, :view
  alias Vote.Voting

  def voting_methods(), do: Voting.method_links
end
