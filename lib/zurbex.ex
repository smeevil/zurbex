defmodule Zurbex do
  @moduledoc """
  This module takes care of the base setup and validation of configs
  """

  @spec get_email_source_dir :: String.t
  def get_email_source_dir, do: Application.get_env(:zurbex, :email_source_dir, File.cwd!)

  @spec get_foundation_source_dir :: String.t
  def get_foundation_source_dir, do: Application.get_env(:zurbex, :foundation_source_dir, File.cwd!)

  @spec get_compiled_dir :: String.t
  def get_compiled_dir, do: Application.get_env(:zurbex, :compiled_dir, File.cwd!)

  @spec check_source_directories :: :ok | {:error, String.t}
  def check_source_directories do
    with \
      :ok <- validate(:foundation_source, File.exists?(get_foundation_source_dir())),
      :ok <- validate(:template_source, File.exists?(get_email_source_dir()))
    do
      :ok
    else
      error -> error
    end
  end

  @spec validate(atom, boolean) :: :ok | {:error, String.t}
  def validate(_, true), do: :ok
  def validate(:foundation_source, false) do
    {:error,
    ~s[
The foundation source directory #{get_foundation_source_dir()} does not exist.
You might want to run `foundation new --framework emails --directory #{get_foundation_source_dir()}`;
If you would like to change the source directory, you can set this in your config with `config :zurbex, foundation_source_dir: "/your/path/here"`.

If you don't have foundation yet, you can install it with `npm install --global foundation-cli`
    ]}
  end
  def validate(:template_source, false) do
    {:error, ~s[
The foundation email template directory #{get_email_source_dir()} does not exist.
You might want to run `mkdir -p #{get_foundation_source_dir()}`
If you want to change the email template directory, you can set this in your config with `config :zurbex, email_source_dir: "/your/path/here"`.
    ]}
  end
end
