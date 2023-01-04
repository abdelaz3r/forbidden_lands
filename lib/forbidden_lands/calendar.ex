defmodule ForbiddenLands.Calendar do
  @moduledoc false

  alias ForbiddenLands.Calendar
  alias ForbiddenLands.Utils.RomanNumerals

  @quarter_by_day 4
  @day_by_week 7
  @day_by_year 365
  @day_by_moon_cycle 28
  @month_shift [45, 91, 137, 183, 228, 274, 319, 365]
  @moon_cycle_shift [1, 14, 15, 28]

  @type t() :: %Calendar{
          quarter: map(),
          day: map(),
          month: map(),
          season: map(),
          moon: map(),
          year: map(),
          count: map()
        }
  defstruct [:quarter, :day, :month, :season, :moon, :year, :count]

  @doc """
  Create a date from a given number of days.
  The date will automatically starts at the beginning of a day (first quarter).
  """
  @spec from_days(integer) :: Calendar.t()
  def from_days(days) do
    new(days * 4 - 3)
  end

  @doc """
  Create a date from a given number of quarter.
  """
  @spec from_quarters(integer) :: Calendar.t()
  def from_quarters(quarters) do
    new(quarters)
  end

  @doc """
  Add a certain amount of [:year | :week | :day | :quarter] to a date.
  The amount can be negative, positive, or null.
  """
  @spec add(Calendar.t(), number(), :year | :week | :day | :quarter) :: Calendar.t()
  def add(%{count: %{quarters: quarters}}, amount, :year) do
    new(quarters + amount * @quarter_by_day * @day_by_year)
  end

  def add(%{count: %{quarters: quarters}}, amount, :week) do
    new(quarters + amount * @quarter_by_day * @day_by_week)
  end

  def add(%{count: %{quarters: quarters}}, amount, :day) do
    new(quarters + amount * @quarter_by_day)
  end

  def add(%{count: %{quarters: quarters}}, amount, :quarter) do
    new(quarters + amount)
  end

  @doc """
  Move a date to the start of a certain date milestone.
  """
  @spec start_of(Calendar.t(), :year | :month | :week | :day) :: Calendar.t()
  def start_of(%{year: %{day: year_day}, count: %{days: days}}, :year) do
    from_days(days - year_day + 1)
  end

  def start_of(calendar, :month) do
    calendar
  end

  def start_of(calendar, :week) do
    calendar
  end

  def start_of(calendar, :day) do
    calendar
  end

  @doc """
  Move a date to the end of a certain date milestone.
  """
  @spec end_of(Calendar.t(), :year | :month | :week | :day) :: Calendar.t()
  def end_of(%{year: %{day: year_day}, count: %{days: days}}, :year) do
    from_days(days - year_day + @day_by_year) |> add(3, :quarter)
  end

  def end_of(calendar, :month) do
    calendar
  end

  def end_of(calendar, :week) do
    calendar
  end

  def end_of(calendar, :day) do
    calendar
  end

  defp new(quarters) do
    days = trunc(Float.ceil(quarters / @quarter_by_day, 0))
    weeks = trunc(Float.ceil(days / @day_by_week, 0))
    years = trunc(Float.ceil((days + 1) / @day_by_year, 0))

    quarter_day = rem(quarters - 1, @quarter_by_day)
    week_day = rem(days - 1, @day_by_week)
    year_day = rem(days, @day_by_year) + 1

    {_month_shift, month_year} =
      @month_shift
      |> Enum.with_index()
      |> Enum.find(fn {shift, _i} -> year_day <= shift end)

    season_year = trunc(month_year / 2)

    day_in_month =
      if month_year > 0,
        do: year_day - Enum.at(@month_shift, month_year - 1),
        else: year_day

    moon_day = rem(days - 1, @day_by_moon_cycle)

    {_moon_shift, moon_index} =
      @moon_cycle_shift
      |> Enum.with_index()
      |> Enum.find(fn {shift, _i} -> moon_day + 1 <= shift end)

    %Calendar{
      quarter: Map.merge(%{number: quarter_day + 1}, Enum.at(quarters(), quarter_day)),
      day: Map.merge(%{number: week_day + 1}, Enum.at(days(), week_day)),
      month: Map.merge(%{number: month_year + 1, day: day_in_month}, Enum.at(months(), month_year)),
      season: Map.merge(%{number: season_year + 1}, Enum.at(seasons(), season_year)),
      moon: Map.merge(%{number: moon_day + 1}, Enum.at(moon_cycles(), moon_index)),
      year: %{
        number: years,
        day: year_day
      },
      count: %{
        quarters: quarters,
        days: days,
        weeks: weeks
      }
    }
  end

  defp quarters() do
    [
      %{key: :morning, name: "matinée", description: "entre 6h et 12h"},
      %{key: :day, name: "après-midi", description: "entre 12h et 18h"},
      %{key: :evening, name: "soirée", description: "entre 18h et minuit"},
      %{key: :night, name: "nuit", description: "entre minuit et 6h"}
    ]
  end

  defp moon_cycles() do
    [
      %{key: :new, name: "nouvelle lune"},
      %{key: :first, name: "lune montante"},
      %{key: :full, name: "pleine lune"},
      %{key: :last, name: "lune descendante"}
    ]
  end

  defp days() do
    [
      %{key: :moonday, name: "moonday", ref: "lundi"},
      %{key: :bloodday, name: "bloodday", ref: "mardi"},
      %{key: :earthday, name: "earthday", ref: "mercredi"},
      %{key: :growthday, name: "growthday", ref: "jeudi"},
      %{key: :harvestday, name: "harvestday", ref: "vendredi"},
      %{key: :stillday, name: "stillday", ref: "samedi"},
      %{key: :sunday, name: "sunday", ref: "dimanche"}
    ]
  end

  defp months() do
    [
      %{key: :springrise, name: "springrise", days_count: 45},
      %{key: :springwane, name: "springwane", days_count: 46},
      %{key: :summerrise, name: "summerrise", days_count: 46},
      %{key: :summerwane, name: "summerwane", days_count: 46},
      %{key: :fallrise, name: "fallrise", days_count: 45},
      %{key: :fallwane, name: "fallwane", days_count: 46},
      %{key: :winterrise, name: "winterrise", days_count: 45},
      %{key: :winterwane, name: "winterwane", days_count: 46}
    ]
  end

  defp seasons() do
    [
      %{key: :spring, name: "printemps"},
      %{key: :summer, name: "été"},
      %{key: :fall, name: "automne"},
      %{key: :winter, name: "hivers"}
    ]
  end

  # temporary

  @spec format(Calendar.t()) :: String.t()
  def format(date) do
    "#{date.quarter.name |> String.capitalize()} du #{date.day.ref} (#{date.day.name |> String.capitalize()}) " <>
      "#{date.month.day} #{date.month.name |> String.capitalize()} (#{RomanNumerals.convert(date.month.number)}) " <>
      "#{date.year.number} AS " <>
      "[#{date.moon.name |> String.capitalize()} (#{date.moon.number})]"
  end
end
