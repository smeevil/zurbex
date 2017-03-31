defmodule Zurbex.Parser do
  require EEx
  
  def slim_to_html(path) do
    File.cwd! <> "/" <> path <> ".slim"
    |> File.read!
    |> Slime.render      
  end

  def slim_file_to_html(file) do
    file
    |> File.read!
    |> Slime.render      
  end
  
  def render_partial(template_path) do
    slim_to_html("source/partials/" <> template_path)    
  end
  
  def html_to_eex(html_source) do     
    html_source 
    |> String.replace(~r[<eex\s?.*?\>], "<%=")
    |> String.replace("</eex>", "%>")    
  end
  
  def eex_to_ast(source, assigns \\ []) do
    EEx.compile_string(source, assigns)                            
  end
end
