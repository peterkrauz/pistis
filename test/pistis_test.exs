defmodule PistisTest do
  use ExUnit.Case
  doctest Pistis

  test "greets the world" do
    assert Pistis.hello() == :world
  end
end
