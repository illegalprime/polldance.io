defmodule VoteWeb.Views.InputHelpers.SelectOneInput do
  use Phoenix.HTML
  alias Phoenix.HTML.Form

  def select_one_input(form, field, options, params \\ []) do
    table_opts = [
      id: Form.input_id(form, field),
      class: "select-one-table",
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
          content_tag(:th, "Select:", class: "opt-select-one-header"),
        ]
      end
    end
  end

  defp table_body(form, field, options, params) do
    options
    |> Enum.with_index()
    |> Enum.map(fn {o, i} -> table_row(form, field, o, i, params) end)
  end

  defp table_row(form, field, opt, opt_idx, _params) do
    id = Form.input_id(form, field)
    name = Form.input_name(form, field)
    value = Form.input_value(form, field)
    checked = value[Integer.to_string(opt_idx)]

    input_opts = [
      id: "#{id}_#{opt_idx}",
      name: "#{name}",
    ] ++ if checked, do: [checked: true], else: []

    content_tag(:tr) do
      [
        content_tag(:td, opt, class: "opt-name"),
        content_tag(:td, class: "opt-select-one") do
          Form.radio_button(form, :nothing, opt_idx, input_opts)
        end,
      ]
    end
  end
end
