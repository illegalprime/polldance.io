defmodule Vote.Token do
  @moduledoc """
  Handles creating and validating tokens.
  """
  alias Vote.Accounts.Account
  alias Vote.Ballots.Ballot
  alias VoteWeb.Endpoint

  @account_verify_salt "bb8fa5ae-7d05-11eb-b555-ab1859c019ff"
  @ballot_salt "ef7f4ab1-bbf3-485e-851f-f913c9cb0d89"

  def generate_new_account_token(%Account{id: id}) do
    Phoenix.Token.sign(Endpoint, @account_verify_salt, id)
  end

  def verify_new_account_token(token) do
    max_age = 86_400 # tokens that are older than a day should be invalid
    Phoenix.Token.verify(Endpoint, @account_verify_salt, token, max_age: max_age)
  end

  def gen_ballot_token(%Ballot{id: id}) do
    Phoenix.Token.sign(Endpoint, @ballot_salt, id, signed_at: 0)
  end

  def verify_ballot_token(token) do
    Phoenix.Token.verify(Endpoint, @ballot_salt, token, max_age: :infinity)
  end
end
