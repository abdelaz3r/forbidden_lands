defmodule ForbiddenLands.RomanNumeralsTest do
  use ExUnit.Case

  alias ForbiddenLands.Utils.RomanNumerals

  describe "convert/1" do
    test "converts numbers 1 to 3999 to their Roman numeral representation" do
      expected_values = %{
        1 => "I",
        2 => "II",
        3 => "III",
        4 => "IV",
        5 => "V",
        6 => "VI",
        7 => "VII",
        8 => "VIII",
        9 => "IX",
        10 => "X",
        11 => "XI",
        12 => "XII",
        13 => "XIII",
        14 => "XIV",
        15 => "XV",
        16 => "XVI",
        17 => "XVII",
        18 => "XVIII",
        19 => "XIX",
        20 => "XX",
        30 => "XXX",
        40 => "XL",
        50 => "L",
        60 => "LX",
        70 => "LXX",
        80 => "LXXX",
        90 => "XC",
        100 => "C",
        200 => "CC",
        300 => "CCC",
        400 => "CD",
        500 => "D",
        600 => "DC",
        700 => "DCC",
        800 => "DCCC",
        900 => "CM",
        1000 => "M",
        2000 => "MM",
        3000 => "MMM",
        3999 => "MMMCMXCIX"
      }

      for {number, expected} <- expected_values do
        assert RomanNumerals.convert(number) == expected
      end
    end

    test "returns an empty string for 0" do
      assert RomanNumerals.convert(0) == ""
    end
  end
end
