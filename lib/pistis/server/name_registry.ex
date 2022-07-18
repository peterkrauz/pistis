defmodule Pistis.Server.NameRegistry do

  def name_pool(), do: [
    "alpha",
    "beta",
    "charlie",
    "delta",
    "echo",
    "foxtrot",
    "golf",
    "hotel",
    "india",
    "juliett",
    "kilo",
    "lima",
    "mike",
    "november",
    "oscar",
    "papa",
    "quebec",
    "romeo",
    "sierra",
    "tango",
    "uniform",
    "victor",
    "whiskey",
    "yankee",
    "zulu",
  ]

  def random_server_name() do
    names = name_pool()
    random_index= :rand.uniform(length(names)) - 1
    names |> Enum.at(random_index) |> String.to_atom()
  end
end
