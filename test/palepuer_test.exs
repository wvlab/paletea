defmodule PalePuerTest do
  use ExUnit.Case, async: true

  describe "evaluate!/2" do
    test "single argument" do
      assert "#FF00FF" == PalePuer.evaluate!("color1", %{"color1" => "#FF00FF"})
    end

    test "sequential arguments" do
      colors = %{
        "color0" => "color3",
        "color1" => "color2",
        "color2" => "color0",
        "color3" => "#FFFFFF"
      }
      assert "#FFFFFF" == PalePuer.evaluate!("color1", colors)
    end

    test "function calls" do
      colors = %{"color1" => "#FF00FF", "color0" => "invert(color1)"}
      assert "#00FF00" == PalePuer.evaluate!("color0", colors)
    end

    test "sequential function calls" do
      colors = %{
        "color1" => "#FF00FF",
        "color0" => "invert(color1)",
        "color2" => "red(color0, 255)",
        "color3" => "blue(color2, 255)"
      }
      assert "#FFFFFF" == PalePuer.evaluate!("color3", colors)
    end
  end

  describe "evaluate/1" do
    test "simple" do
      colors = %{"color0" => "#FFFFFF", "color1" => "color0"}
      assert %{"color0" => "#FFFFFF", "color1" => "#FFFFFF"} == PalePuer.evaluate!(colors)
    end

    test "sequential" do
      colors = %{
        "color0" => "color3",
        "color1" => "color2",
        "color2" => "color0",
        "color3" => "#FFFFFF"
      }
      assert %{"color0" => "#FFFFFF", "color1" => "#FFFFFF", "color2" => "#FFFFFF", "color3" => "#FFFFFF"} == PalePuer.evaluate!(colors)
    end
  end
end
