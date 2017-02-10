defmodule Zurbex.Precompile do    
  defmacro __using__(_opts) do
    quote do
      @before_compile unquote(__MODULE__)
      import Zurbex.Gettext
    end
  end
  
  defmacro __before_compile__(_env) do    
    require EEx
    IO.puts("Precompiling mail templates")
    files = File.cwd! <> "/source/pages/" |> Path.join("**/*.slim") |> Path.wildcard()    
    
    functions = for path <- files do
      relative = template_relative_path(path, File.cwd! <> "/source/pages") 
      source = compile_slim_to_eex(relative)
      eex = EEx.compile_string(source)
      template_name = relative_to_function_name(relative) 
                
      IO.puts "  * #{template_name}"
      quote bind_quoted: [], unquote: true do
        @file "#{unquote(relative)}.ex"
        def render(unquote(template_name), var!(assigns)) do
         {string, _} = Code.eval_quoted(unquote(eex), var!(assigns))
         string
        end
      end    
    end
     
    templates = for path <- files do
      path |> template_relative_path(File.cwd! <> "/source/pages") |> relative_to_function_name
    end     
    
    catch_all = quote do 
      def render(unknown_template, _) do
        raise ~s[Unknown template #{inspect unknown_template}
Known templates:
#{Enum.map(unquote(templates), fn template -> ":#{template} \n" end)}]
      end
    end
    
    {functions, catch_all}
  end

  defp compile_slim_to_eex(relative) do
   "source/pages/" <> relative 
   |> Zurbex.Parser.slim_to_html 
   |> Zurbex.Parser.html_to_eex 
  end
  
  defp template_relative_path(path, root) do
    path
    |> Path.rootname()
    |> Path.relative_to(root)
  end
  
  defp relative_to_function_name(relative) do
    relative 
    |> String.replace("/", "_") 
    |> String.to_atom
  end
end
