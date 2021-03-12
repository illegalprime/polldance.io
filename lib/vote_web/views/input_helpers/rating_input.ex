defmodule VoteWeb.Views.InputHelpers.RatingInput do
  use Phoenix.HTML
  alias Phoenix.HTML.Form

  def rating_input(form, field, options, params \\ []) do
    table_opts = [
      id: Form.input_id(form, field),
      class: "rank-table",
    ]
    content_tag(:table, table_opts) do
      [
        table_header(),
        table_body(form, field, options, params),
      ]
    end
  end

  defp table_header() do
    content_tag(:thead) do
      content_tag(:tr) do
        [
          content_tag(:th, "Option", class: "opt-name-header"),
          content_tag(:th, "Rating", class: "opt-rating-header"),
        ]
      end
    end
  end

  defp table_body(form, field, options, params) do
    options
    |> Enum.with_index()
    |> Enum.map(fn {o, i} -> table_row(form, field, o, i, params) end)
  end

  defp table_row(form, field, opt, opt_idx, params) do
    content_tag(:tr) do
      [
        content_tag(:td, opt, class: "opt-name"),
        content_tag(:td, class: "opt-rating") do
          content_tag(:div, class: "stars-container") do
            make_stars(form, field, opt_idx, params)
          end
        end,
      ]
    end
  end

  defp make_stars(form, field, idx, params) do
    id = Form.input_id(form, field)
    name = Form.input_name(form, field)
    values = Form.input_value(form, field)

    Enum.map(1..params[:n], fn i ->
      input_opts = [
        class: "rank-star",
        id: "#{id}_#{idx}_#{i}",
        name: "#{name}[#{idx}]",
      ] ++ (if values[idx] == i do [checked: true] else [] end)
      [
        Form.radio_button(form, :nothing, i, input_opts),
        Form.label(for: input_opts[:id]) do "" end,
      ]
    end)
  end
end
