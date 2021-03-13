defmodule VoteWeb.Views.InputHelpers.RankingInput do
  use Phoenix.HTML
  alias Phoenix.HTML.Form

  # TODO: what happens when fields are added while a user is dragging?

  def ranking_input(form, field, options, opts \\ []) do
    id = Form.input_id(form, field)
    values = Form.input_value(form, field)

    # add the divider to the list of rows to render (-1 is the divider)
    options_idxs = Enum.map(-1..length(options) - 1, &to_string/1)
    # get any new options that might have been added
    new_options = options_idxs |> Enum.filter(&(!Map.has_key?(values, &1)))
    # there are no holes in rank voting, so sort and convert to list
    render_idxs = values
    |> Map.to_list()
    |> Enum.sort_by(fn {_, i} -> i end)
    |> Enum.map(fn {n, _} -> n end)
    |> Enum.concat(new_options)

    table_opts = [
      id: id,
      class: "drag-table",
      phx_hook: "DragTable",
      data_idx: opts[:item_idx],
    ]
    content_tag(:table, table_opts) do
      [
        table_header(),
        table_body(form, field, render_idxs, options),
        Form.hidden_input(form, :nothing, id: "#{id}_trigger", name: "ignore"),
      ]
    end
  end

  defp table_header() do
    content_tag(:thead) do
      content_tag(:tr) do
        [
          content_tag(:th, "Rank", class: "ta-center"),
          content_tag(:th, "Option", class: "opt-name-header"),
          content_tag(:th, "⌃/⌄", class: "ta-center drag-header"),
        ]
      end
    end
  end

  defp table_body(form, field, idxs, options) do
    div_idx = Enum.find_index(idxs, fn i -> i == "-1" end)

    content_tag(:tbody) do
      idxs
      |> Enum.with_index()
      |> Enum.map(fn {opt_idx, i} ->
        opt_idx = String.to_integer(opt_idx)
        opt = Enum.at(options, opt_idx)
        cond do
          i < div_idx  -> table_row(form, field, i, opt, opt_idx, false)
          i == div_idx -> table_divider(form, field)
          i > div_idx  -> table_row(form, field, i, opt, opt_idx, true)
        end
      end)
    end
  end

  defp table_divider(form, field) do
    message = content_tag(:td, colspan: 3, class: "ta-center") do
      raw("↑ Drag Options Above This Line ↑")
    end
    input_opts = [
      id: "#{Form.input_id(form, field)}_divider",
      name: Form.input_name(form, field) <> "[]",
      value: -1,
    ]
    content_tag(:tr, data_ignore: "true", class: "rank-divider") do
      [
        message,
        Form.hidden_input(form, :nothing, input_opts),
      ]
    end
  end

  defp table_row(form, field, rank, opt_name, opt_idx, over?) do
    input_opts = [
      id: "#{Form.input_id(form, field)}_#{rank}",
      name: Form.input_name(form, field) <> "[]",
      value: opt_idx,
    ]
    rank_col = if over? do "—" else rank + 1 end
    content_tag(:tr) do
      [
        content_tag(:td, rank_col, class: "opt-rank ta-center"),
        content_tag(:td, opt_name, class: "opt-name"),
        content_tag(:td, "☰", class: "opt-drag ta-center"),
        Form.hidden_input(form, :nothing, input_opts),
      ]
    end
  end
end
