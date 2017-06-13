defmodule Zurbex.Precompile do
  @moduledoc """
  This module will parse the zurb source templates, extract eex, and convert the templates to render functions
  """

  defmacro __using__(options) do
    quote do
      @before_compile unquote(__MODULE__)
      import unquote(options[:gettext])
    end
  end

  defmacro __before_compile__(_env) do
    require EEx

    case Zurbex.check_source_directories() do
      {:error, message} -> raise message
      _ -> nil
    end

    build_zurb_mail()
    convert_zurb_mail_to_functions()
  end

  defp build_zurb_mail do
    IO.puts("Precompiling mail templates")
    System.cmd("/usr/bin/env", ["yarn", "install"], cd: Zurbex.get_foundation_source_dir())
    System.cmd("/usr/bin/env", ["node", "./node_modules/gulp-cli/bin/gulp.js", "build", "--production"], cd: Zurbex.get_foundation_source_dir())
  end

  def convert_zurb_mail_to_functions do
    #mark source files as external, so when they are changed, elixir will automatically recompile
    external_resources = for file <- (Zurbex.get_email_source_dir() |> Path.join("**/*.{html,slim}") |> Path.wildcard()) do
      quote do
        @external_resource unquote(file)
      end
    end

    files = Zurbex.get_foundation_source_dir() <> "/dist/" |> Path.join("**/*.html") |> Path.wildcard()
    functions = for file <- files do
      source = file |> File.read!|> Zurbex.Parser.html_to_eex
      eex = EEx.compile_string(source)
      relative = template_relative_path(file, Zurbex.get_foundation_source_dir() <> "/dist")
      template_name = relative_to_function_name(relative)


      IO.puts "  * #{template_name}"
      quote do
        @file unquote(file)
        @spec render(Atom.t, List.t) :: binary
        def render(unquote(template_name), var!(assigns)) do
         {string, _} = Code.eval_quoted(unquote(eex), var!(assigns))
         string
        end
      end
    end

    templates = for file <- files do
      file |> template_relative_path(Zurbex.get_foundation_source_dir() <> "/dist/") |> relative_to_function_name
    end

    helpers = quote do
      # mark source dir as external, so when new files are added or removed (not changed!), elixir will automatically recompile
      @external_resource unquote(Zurbex.get_email_source_dir())
      def render(unknown_template, _) do
        {_, likely} = Enum.map(templates(), fn template ->
          {String.jaro_distance(Atom.to_string(unknown_template), Atom.to_string(template)), template}
        end) |> Enum.max
        raise ~s[Unknown template #{inspect unknown_template}, did you mean #{inspect likely} ?
Known templates:
#{Enum.map(templates(), fn template -> ":#{template} \n" end)}]
      end

      @spec templates :: [Atom.t]
      def templates, do: unquote(templates)
    end
    {external_resources, {functions, helpers}}
  end

  @spec template_relative_path(String.t, String.t) :: String.t
  defp template_relative_path(path, root) do
    path
    |> Path.rootname()
    |> Path.relative_to(root)
  end

  @spec relative_to_function_name(String.t) :: Atom.t
  defp relative_to_function_name(relative) do
    relative
    |> String.replace("/", "_")
    |> String.to_atom
  end
end
