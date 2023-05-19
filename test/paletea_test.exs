defmodule PaleteaTest do
  use ExUnit.Case
  doctest Paletea

  test "greets the world" do
    assert Paletea.hello() == :world
  end
end
