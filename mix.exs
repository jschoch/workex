defmodule Workex.Mixfile do
  use Mix.Project

  def project do
    [ app: :workex,
      version: "0.0.1",
      deps: deps ]
  end

  def application do
    [
    applications: [:folsom] 
    ]
  end

  defp deps do
    [
      {:exactor, github: "sasa1977/exactor"},
      {:folsom, git: "https://github.com/boundary/folsom.git" }
    ]
  end
end
