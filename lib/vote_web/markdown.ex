defmodule Vote.Markdown do
  use PhoenixHtmlSanitizer, :basic_html

  def render_markdown(markdown) do
    markdown
    |> Earmark.as_html!()
    |> sanitize()
  end
end
