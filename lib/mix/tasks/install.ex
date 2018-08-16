# manuall install :

#yarn globall add foundation-cli
#foundation new --framework emails --directory zurb_for_email
#copy templates to template_root


defmodule Mix.Tasks.Zurbex.Install do
  use Mix.Task
  @shortdoc "Will setup and install Zurb Email node dependencies and create source dirs."

  def template_root, do: Application.get_env(:zurbex, :email_template_dir, File.cwd!)
  def zurb_root, do: Application.get_env(:zurbex, :foundation_source_dir, File.cwd!)

  @spec run(list) :: :ok | {:error, String.t}
  def run(_args) do
    case Zurbex.check_source_directories() do
      :ok -> install()
      {:error, message} -> IO.puts(message)
    end
    :ok
  end

  @spec install :: :ok
  def install do
    src = zurb_root() <> "/src"
    dest = template_root()

    case File.lstat(src) do
      {:ok, %{type: :symlink}} -> {:error, "already installed"}
      _ ->
        File.cp_r!(src, dest)
        File.rm_rf!(src)
        File.ln_s(dest, src)
        :ok
    end
  end
end
