defmodule BlockingBuffer.MixProject do
  use Mix.Project

  def project do
    [
      app: :blocking_buffer,
      version: "0.1.0",
      elixir: "~> 1.17-rc",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {BlockingBuffer.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:styler, ">= 1.0.0-alpha.0", only: [:dev, :test], runtime: false}
    ]
  end
end
