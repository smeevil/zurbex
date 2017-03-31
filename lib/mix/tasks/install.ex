# manuall install :

#yarn globall add foundation-cli
#foundation new --framework emails --directory zurb_for_email
#copy templates to source_root


defmodule Mix.Tasks.Zurb.Install do
  use Mix.Task
  @shortdoc "Will setup and install Zurb Email node dependencies and create source dirs."
  
  @source_root Application.get_env(:zurbex, :email_source_dir, File.cwd! <> "/source/pages/")
  @zurb_root Application.get_env(:zurbex, :foundation_source_dir, File.cwd! <> "/zurb/")
   
  def run(_args) do
    dirs = ~w(assets layouts pages partials) 
    Enum.each(dirs, fn dir -> move_dirs_and_copy_templates(@zurb_root <> "/src/" <> dir, @source_root <> "/" <> dir)end)
  end
  
  defp move_dirs_and_copy_templates(src, dst) do
    File.cp_r!(src, dst)
    File.rm_rf!(src)
    File.cp_r(dst, src)
  end
  
#  def run(_args) do    
#    installer = determine_installer() 
#    
#    cmd_for_package = case installer do
#      "yarn" -> ["global" ,"add"]
#      "npm" -> ["install", "--global"]
#    end
#    
#    Mix.shell.info "Using #{installer} to install globally install Zurb for Email, this may take a few minutes..."
#    System.cmd("/usr/bin/env", [installer] ++ cmd_for_package ++ ["foundation-cli"], cd: get_install_dir())
#    
#    Mix.shell.info "Creating Zurb for Email sources at #{get_install_dir()}, this may take a few minutes..."
#    System.cmd("/usr/bin/env", ["foundation", "new", "--framework", "emails", "--directory", "zurb"], cd: get_install_dir())
#  end
#  
  defp get_install_dir do
    __DIR__ 
    |> String.split("/") 
    |> Enum.drop(-3) 
    |> Enum.join("/")
  end
  
  defp determine_installer do
    {_, yarn} = System.cmd("which", ["yarn"])
    {_, npm}= System.cmd("which", ["npm"])
    
    cond do
      yarn == 0 -> "yarn" 
      npm == 0 -> "npm"
      true -> raise "Zurbex needs either npm or yarn to install its dependencies" 
    end
  end
end
