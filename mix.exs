defmodule Lullabeam.MixProject do
  use Mix.Project
  @app :lullabeam

  def project do
    [
      app: @app,
      version: "0.1.0",
      elixir: "~> 1.6",
      archives: [nerves_bootstrap: "~> 1.6"],
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.target() != :host,
      aliases: [loadconfig: [&bootstrap/1]],
      deps: deps(),
      releases: [{@app, release()}],
      preferred_cli_target: [run: :host, test: :host]
    ]
  end

  # Starting nerves_bootstrap adds the required aliases to Mix.Project.config()
  # Aliases are only added if MIX_TARGET is set.
  def bootstrap(args) do
    # System.put_env("MIX_TARGET", "lullabeam_rpi3")
    Application.start(:nerves_bootstrap)
    Mix.Task.run("loadconfig", args)
  end

  def release do
    [
      overwrite: true,
      cookie: "#{@app}_cookie",
      include_erts: &Nerves.Release.erts/0,
      steps: [&Nerves.Release.init/1, :assemble],
      strip_beams: Mix.env() == :prod
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Lullabeam.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Typical Nerves stuff
      {:nerves, "~> 1.5.3", runtime: false},
      {:shoehorn, "~> 0.6"},
      {:ring_logger, "~> 0.6"},
      # {:toolshed, "~> 0.2"},
      {:nerves_runtime, "~> 0.6", targets: :lullabeam_rpi3},

      # Control CPU speed & power usage
      {:power_control, "~> 0.1.0", targets: :lullabeam_rpi3},

      # Watch for USB inputs
      {:input_event, "~> 0.2.1", targets: :lullabeam_rpi3},

      # compiled with mpv
      {:lullabeam_rpi3,
       git: "git@github.com:nathanl/lullabeam_rpi3.git",
       tag: "v1.6.2",
       runtime: false,
       nerves: [compile: false],
       targets: :lullabeam_rpi3}

      # compiled with mpv
      # {:lullabeam_rpi3, path: "/Users/nathanl/code/experiments/lullabeam_rpi3", runtime: false, nerves: [compile: true], targets: :lullabeam_rpi3}
    ]
  end
end
