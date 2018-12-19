defmodule Mix.Tasks.Zurbex.Compile do
  use Mix.Task
  @shortdoc "Will compile the Zurb templates to html so they can be parsed by zurbex"

  def template_root, do: Application.get_env(:zurbex, :email_template_dir, File.cwd!)
  def zurb_root, do: Application.get_env(:zurbex, :foundation_source_dir, File.cwd!)
  def compiled_root, do: Application.get_env(:zurbex, :compiled_dir, File.cwd!)

  @spec run(list) :: :ok | {:error, String.t}
  def run(_args) do
    case Zurbex.check_source_directories() do
      :ok -> compile()
      {:error, message} -> IO.puts(message)
    end
    :ok
  end

  @spec compile :: :ok
  def compile() do
    IO.puts "checking for #{inspect Zurbex.get_foundation_source_dir()}"
    if File.exists?(Zurbex.get_foundation_source_dir() <> "/node_modules") do

      IO.puts("Precompiling mail templates, this might take a while...")
      System.cmd(
        "/usr/bin/env",
        ["node", "./node_modules/gulp-cli/bin/gulp.js", "build", "--production"],
        cd: Zurbex.get_foundation_source_dir()
      )
      File.mkdir_p(compiled_root())
      Zurbex.get_foundation_source_dir() <> "/dist/"
      |> File.ls!
      |> IO.inspect(label: "listing files")
      |> Enum.filter(&(String.match?(&1, ~r/.html$/)))
      |> IO.inspect(label: "html files")
      |> Enum.each(&(File.cp(Zurbex.get_foundation_source_dir() <> "/dist/" <> &1, compiled_root() <> "/" <> &1)))
      :ok
    else
      IO.puts "node_modules not found in #{
        Zurbex.get_foundation_source_dir() <> "/node_modules"
      }, running yarn install..."
      System.cmd(
        "/usr/bin/env",
        ["yarn", "install"],
        cd: Zurbex.get_foundation_source_dir()
      )
      if File.exists?(Zurbex.get_foundation_source_dir() <> "/node_modules") do
        compile()
      else
        IO.puts "Could not install the node modules in #{
          Zurbex.get_foundation_source_dir()
        }... I need some manual help!"
      end
    end
  end
end
