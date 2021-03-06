defmodule Litelist.Mixfile do
  use Mix.Project

  def project do
    [
      app: :litelist,
      version: "0.1.0",
      elixir: "~> 1.6.1",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Litelist.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 4.0.0"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, "~> 0.14.1"},
      {:phoenix_html, "~> 2.13"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.16.1"},
      {:plug_cowboy, "~> 2.0.1"},
      {:plug, "~> 1.7.1"},
      {:guardian, "~> 1.0"},
      {:comeonin, "~> 4.1.2"},
      {:bcrypt_elixir, "~> 0.12"},
      {:ex_machina, "~> 2.2.2"},
      {:faker_elixir_octopus, "~> 1.0.2"},
      {:excoveralls, "~> 0.10", only: :test},
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.16"},
      {:quantum, "~> 2.3.3"},
      {:timex, "~> 3.4.2"},
      {:arc, "~> 0.11.0"},
      {:arc_ecto, "~> 0.11.1"},
      {:uuid, "~> 1.1"},
      {:phoenix_html_simplified_helpers, "~> 2.1"},
      {:jason, "~> 1.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "ecto.seed": ["run priv/repo/seeds.exs"],
      "test": ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
