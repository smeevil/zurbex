defmodule Zurbex.Precompile do    
  
  defmacro __using__(options) do
    quote do
      @before_compile unquote(__MODULE__)
      import unquote(options[:gettext])
    end
  end
  
  defmacro __before_compile__(_env) do    
    require EEx
    check_source_directories()
    copy_html_to_zurb_source_dir()
    maybe_compile_slim_to_zurb_source_dir()
    build_zurb_mail()
    convert_zurb_mail_to_functions()
  end

  defp maybe_compile_slim_to_zurb_source_dir do
    get_email_source_dir() 
    |> Path.join("**/*.slim") 
    |> Path.wildcard()
    |> Enum.each(&compile_slim_to_zurb_source_dir/1)
  end
  
  defp compile_slim_to_zurb_source_dir(file) do
    html = Zurbex.Parser.slim_file_to_html(file)
    relative = file |> Path.relative_to(get_email_source_dir() <> "/pages/") |> Path.rootname
    dir = (get_foundation_source_dir() <> "/src/pages/" <> relative) |> Path.dirname
    File.mkdir_p!(dir)
    File.write!(get_foundation_source_dir() <> "/src/pages/" <> relative <> ".html", html, [:utf8])
  end
  
  defp copy_html_to_zurb_source_dir do
    #FIXME clear source dir first
    files = get_email_source_dir() <> "/pages/"|> Path.join("**/*.html") |> Path.wildcard()
    for file <- files do
      relative = file |> Path.relative_to(get_email_source_dir() <> "/pages/")      
      dir = (get_foundation_source_dir() <> "/src/pages/" <> relative) |> Path.dirname
      File.mkdir_p!(dir)
      File.cp!(file, get_foundation_source_dir() <> "/src/pages/" <> relative)
    end
  end
  
  defp build_zurb_mail do
    IO.puts("Precompiling mail templates")
    System.cmd("/usr/bin/env", ["node", "./gulp.js", "build", "--production"], cd: get_foundation_source_dir() <> "/node_modules/gulp-cli/bin/")
  end
  
  def convert_zurb_mail_to_functions do
    #mark source files as external, so when they are changed, elixir will automatically recompile
    external_resources = for file <- (get_email_source_dir() |> Path.join("**/*.{html,slim}") |> Path.wildcard()) do
      quote do
        @external_resource unquote(file)
      end
    end

    files = get_foundation_source_dir() <> "/dist/" |> Path.join("**/*.html") |> Path.wildcard()                 
    functions = for file <- files do
      source = file |> File.read!|> Zurbex.Parser.html_to_eex 
      eex = EEx.compile_string(source)
      relative = template_relative_path(file, get_foundation_source_dir() <> "/dist")
      template_name = relative_to_function_name(relative) 
      

      IO.puts "  * #{template_name}"
      quote do
        @file unquote(file)
        def render(unquote(template_name), var!(assigns)) do
         {string, _} = Code.eval_quoted(unquote(eex), var!(assigns))
         string
        end
      end
    end
    
    templates = for file <- files do
      file |> template_relative_path(get_foundation_source_dir() <> "/dist/") |> relative_to_function_name
    end     
    
    helpers = quote do
      # mark source dir as external, so when new files are added or removed (not changed!), elixir will automatically recompile
      @external_resource unquote(get_email_source_dir())
      def render(unknown_template, _) do
        {_, likely} = Enum.map(templates(), fn template ->
          {String.jaro_distance(Atom.to_string(unknown_template), Atom.to_string(template)), template}
        end) |> Enum.max
        raise ~s[Unknown template #{inspect unknown_template}, did you mean #{inspect likely} ?
Known templates:
#{Enum.map(templates(), fn template -> ":#{template} \n" end)}]
      end
      
      def templates, do: unquote(templates)
    end
    {external_resources, {functions, helpers}}
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
  
  defp check_source_directories do
    unless File.exists?(get_foundation_source_dir()), do: raise "The zurbex zurb root directory #{get_foundation_source_dir()} does not exist. You might want to run 'foundation new --framework emails --directory #{get_foundation_source_dir()}'"
    unless File.exists?(get_email_source_dir()), do: raise "The zurbex source directory #{get_email_source_dir()} does not exist, please check your config!"
  end
  
  defp get_email_source_dir, do: Application.get_env(:zurbex, :email_source_dir, File.cwd! <> "/source/pages/")
  defp get_foundation_source_dir, do: Application.get_env(:zurbex, :foundation_source_dir, File.cwd! <> "/zurb/")
end
