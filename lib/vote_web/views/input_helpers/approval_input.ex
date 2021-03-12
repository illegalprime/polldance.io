defmodule VoteWeb.Views.InputHelpers.ApprovalInput do
  use Phoenix.HTML
  alias Phoenix.HTML.Form

  def approval_input(form, field, options, params \\ []) do
    table_opts = [
      id: Form.input_id(form, field),
      class: "approval-table",
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
          content_tag(:th, "Approve?", class: "opt-approval-header"),
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
    id = Form.input_id(form, field)
    name = Form.input_name(form, field)
    values = Form.input_value(form, field)

    input_opts = [
      id: "#{id}_#{opt_idx}",
      name: "#{name}[#{opt_idx}]",
    ] ++ (if values[opt_idx] == 1 do [checked: true] else [] end)

    content_tag(:tr) do
      [
        content_tag(:td, opt, class: "opt-name"),
        content_tag(:td, class: "opt-approval") do
          Form.checkbox(form, :nothing, input_opts)
        end,
      ]
    end
  end
end
