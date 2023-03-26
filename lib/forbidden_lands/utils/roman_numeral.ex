defmodule ForbiddenLands.Utils.RomanNumerals do
  @moduledoc """
  Converts a positive integer as its parameter to a string containing
  the Roman Numeral representation of that integer.
  """

  @numerals [
    {1000, "M"},
    {900, "CM"},
    {500, "D"},
    {400, "CD"},
    {100, "C"},
    {90, "XC"},
    {50, "L"},
    {40, "XL"},
    {10, "X"},
    {9, "IX"},
    {5, "V"},
    {4, "IV"},
    {1, "I"}
  ]

  def convert(number) do
    convert(number, @numerals)
  end

  defp convert(0, _) do
    ""
  end

  defp convert(_number, []) do
    ""
  end

  defp convert(number, [{arabic, roman} | t]) when number >= arabic do
    "#{roman}#{convert(number - arabic, [{arabic, roman} | t])}"
  end

  defp convert(number, [_ | t]) do
    convert(number, t)
  end
end
