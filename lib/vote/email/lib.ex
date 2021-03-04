defmodule Vote.Email do
  @moduledoc """
  Handles sending email via Bamboo (SendGrid)
  """
  require Logger
  import Bamboo.Email
  alias __MODULE__.Mailer

  @verify_subject Application.get_env(:vote, __MODULE__)[:verify_subject]
  @verify_from Application.get_env(:vote, __MODULE__)[:verify_from]
  @verify_body Application.get_env(:vote, __MODULE__)[:verify_body]

  def send_account_verification_email(account, url) do
    new_email()
    |> to(account.email)
    |> subject(@verify_subject)
    |> from(@verify_from)
    |> text_body(@verify_body <> url)
    |> Mailer.deliver_now()
  end
end
