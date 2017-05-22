defmodule Zurbex.Parser do
  @moduledoc """
  This module takes care of rendering different input formats back to html
  """
  require EEx

  @spec slim_to_html(String.t) :: String.t
  def slim_to_html(path) do
    File.cwd! <> "/" <> path <> ".slim"
    |> File.read!
    |> Slime.render
  end

  @spec slim_file_to_html(String.t) :: String.t
  def slim_file_to_html(file) do
    file
    |> File.read!
    |> Slime.render
  end

  @spec render_partial(String.t) :: String.t
  def render_partial(template_path) do
    slim_to_html("source/partials/" <> template_path)
  end

  @spec html_to_eex(String.t) :: String.t
  def html_to_eex(html_source) do
    html_source
    |> String.replace(~r[<eex\s?.*?\>], "<%=")
    |> String.replace("</eex>", "%>")
  end

  @spec eex_to_ast(String.t, List.t) :: String.t
  def eex_to_ast(source, assigns \\ []) do
    EEx.compile_string(source, assigns)
  end
end
