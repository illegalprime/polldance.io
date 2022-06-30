defmodule VoteWeb.Views.InputHelpers.RatingInput do
  use Phoenix.HTML
  alias Phoenix.HTML.Form

  def rating_input(form, field, item, params \\ []) do
    table_opts = [
      class: "rank-table",
    ]
    content_tag(:table, table_opts) do
      [
        table_header(),
        table_body(form, field, item, params),
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

  defp table_body(form, field, item, params) do
    item.options
    |> Enum.with_index()
    |> Enum.map(fn {o, i} -> table_row(form, field, o, i, item, params) end)
  end

  defp table_row(form, field, opt, opt_idx, item, params) do
    id = Form.input_id(form, :comments)
    name = Form.input_name(form, :comments)
    values = Form.input_value(form, :comments) || %{}

    option_label = if item.comments do
      comment_input_attrs = [
        name: "#{name}[#{opt_idx}]",
        id: "#{id}_#{opt_idx}",
        value: Map.get(values, Integer.to_string(opt_idx), ""),
        placeholder: "Leave some comments here!",
      ]
      content_tag(:td, class: "opt-name") do
        [
          content_tag(:p, opt),
          Form.textarea(form, :na, comment_input_attrs)
        ]
      end
    else
      content_tag(:td, opt, class: "opt-name")
    end

    content_tag(:tr) do
      [
        option_label,
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

    0..params[:n]
    |> Enum.reverse()
    |> Enum.map(fn i ->
      checked = Map.get(values, Integer.to_string(idx), 0) == i
      input_opts = [
        class: "rank-star",
        id: "#{id}_#{idx}_#{i}",
        name: "#{name}[#{idx}]",
      ] ++ if checked, do: [checked: true], else: []
      [
        Form.radio_button(form, :nothing, i, input_opts),
        Form.label(for: input_opts[:id]) do "" end,
      ]
    end)
  end
end
