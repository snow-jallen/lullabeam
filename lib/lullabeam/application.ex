defmodule Lullabeam.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  @target Mix.target()

  use Application

  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [
      strategy: :one_for_one,
      name: Lullabeam.Supervisor,
      shutdown: 5_000,
      max_restarts: 20
    ]

    Supervisor.start_link(children(@target), opts)
  end

  def children(:host = env) do
    [
      {Lullabeam.RuntimeSupervisor, env}
    ]
  end

  def children(env) do
    [
      Lullabeam.RPiSetup,
      {Lullabeam.RuntimeSupervisor, env}
    ]
  end
end
