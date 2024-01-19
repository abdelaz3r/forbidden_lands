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

  @spec convert(pos_integer()) :: String.t()
  def convert(number) when is_integer(number) and number >= 0 do
    do_convert(number, @numerals)
  end

  defp do_convert(0, _), do: ""
  defp do_convert(_number, []), do: ""

  defp do_convert(number, [{arabic, roman} | t]) when number >= arabic,
    do: "#{roman}#{do_convert(number - arabic, [{arabic, roman} | t])}"

  defp do_convert(number, [_ | t]), do: do_convert(number, t)
end
