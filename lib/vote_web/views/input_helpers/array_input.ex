defmodule VoteWeb.Views.InputHelpers.ArrayInput do
  use Phoenix.HTML
  require Logger
  alias Phoenix.HTML.Form

  def array_input(form, field, input_opts, rm_opts, _add_opts) do
    values = Form.input_value(form, field) || []
    id = Form.input_id(form, field)

    # always add one extra element
    values =
      case List.last(values) do
        "" -> values
        _l -> values ++ [""]
      end

    list_items = values
    |> Enum.with_index()
    |> Enum.map(fn {v, i} ->
      form_elements(form, field, v, i, input_opts, rm_opts)
    end)

    array = content_tag(:ol, id: "#{id}_container", class: "input_container") do
      list_items
    end

    content_tag(:div) do
      [
        array,
        # link(add_opts[:title], [to: "#"] ++ add_opts)
      ]
    end
  end

  defp form_elements(form, field, value, index, input_opts, rm_opts) do
    type = Form.input_type(form, field)
    id = Form.input_id(form, field)

    input_opts = [
      name: Form.input_name(form, field) <> "[]",
      value: value,
      id: "#{id}_#{index}",
    ] ++ input_opts

    rm_opts = [
      to: "#",
      phx_value_idx: index,
      tabindex: -1,
    ] ++ rm_opts

    content_tag :li do
      [
        apply(Form, type, [form, field, input_opts]),
        link(rm_opts[:title], rm_opts),
      ]
    end
  end
end
