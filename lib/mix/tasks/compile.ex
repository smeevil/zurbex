defmodule Mix.Tasks.Zurbex.Compile do
  use Mix.Task
  @shortdoc "Will compile the Zurb templates to html so they can be parsed by zurbex"

  def template_root, do: Application.get_env(:zurbex, :email_template_dir, File.cwd!)
  def zurb_root, do: Application.get_env(:zurbex, :foundation_source_dir, File.cwd!)

  @spec run(List.t) :: :ok | {:error, String.t}
  def run(_args) do
    case Zurbex.check_source_directories() do
      :ok -> compile()
      {:error, message} -> IO.puts(message)
    end
    :ok
  end

  @spec compile :: :ok
  def compile do
    IO.puts("Precompiling mail templates")
    System.cmd("/usr/bin/env", ["node", "./node_modules/gulp-cli/bin/gulp.js", "build", "--production"], cd: Zurbex.get_foundation_source_dir())
    File.mkdir_p(File.cwd! <> "/priv/zurbex/")
    Zurbex.get_foundation_source_dir() <> "/dist/"
    |> File.ls!
    |> Enum.filter(&(String.match?(&1, ~r/.html$/)))
    |> Enum.each(&(File.cp(Zurbex.get_foundation_source_dir() <> "/dist/" <> &1, File.cwd! <> "/priv/zurbex/" <> &1)))
    :ok
  end
end
