defmodule Lullabeam.MixProject do
  use Mix.Project

  def project do
    [
      app: :lullabeam,
      version: "0.1.0",
      elixir: "~> 1.6",
      archives: [nerves_bootstrap: "~> 1.0"],
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.target() != :host,
      aliases: [loadconfig: [&bootstrap/1]],
      deps: deps()
    ]
  end

  # Starting nerves_bootstrap adds the required aliases to Mix.Project.config()
  # Aliases are only added if MIX_TARGET is set.
  def bootstrap(args) do
    # System.put_env("MIX_TARGET", "lullabeam_rpi3")
    Application.start(:nerves_bootstrap)
    Mix.Task.run("loadconfig", args)
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
      {:nerves, "~> 1.4", runtime: false},
      {:shoehorn, "~> 0.4"},
      {:ring_logger, "~> 0.6"},
      # {:toolshed, "~> 0.2"},
      {:nerves_runtime, "~> 0.6", targets: :lullabeam_rpi3},

      # Control CPU speed & power usage
      {:power_control, "~> 0.1.0", targets: :lullabeam_rpi3},

      # Watch for USB inputs
      {:input_event, "~> 0.2.1", targets: :lullabeam_rpi3},

      # compiled with mpv
      {:lullabeam_rpi3, git: "git@github.com:nathanl/lullabeam_rpi3.git", tag: "v1.6.2", runtime: false, nerves: [compile: false], targets: :lullabeam_rpi3}

      # compiled with mpv
      # {:lullabeam_rpi3, path: "/Users/nathanl/code/experiments/lullabeam_rpi3", runtime: false, nerves: [compile: true], targets: :lullabeam_rpi3}
    ]
  end
end
