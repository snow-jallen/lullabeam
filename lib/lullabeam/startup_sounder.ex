defmodule Lullabeam.StartupSounder do
  @moduledoc """
  Doesn't use mpv just because DJ expects to be in charge of it, and free to
  kill it on startup and any other time.
  """
  use GenServer
  use Lullabeam.Log

  def child_spec(env) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [env]},
      restart: :transient
    }
  end

  def start_link(env) do
    GenServer.start_link(__MODULE__, %{env: env}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    {:ok, state, {:continue, :play}}
  end

  @impl true
  def handle_continue(:play, %{env: env} = state) do
    log("playing startup sound!")
    play_startup_sound(env)
    {:stop, :normal, state}
  end

  def play_startup_sound(env) do
    Lullabeam.SoundEffects.play(env, :startup)
    IO.puts "played startup sound!"
  end
end
