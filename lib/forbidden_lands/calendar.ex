defmodule ForbiddenLands.Calendar do
  @moduledoc false

  alias ForbiddenLands.Calendar

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
  Create a calendar form a given string-format date following the format `y.m.d`.
  """
  @spec from_date(String.t()) :: {:ok, Calendar.t()} | {:error, :atom}
  def from_date(date) when is_binary(date) do
    try do
      [year, month, day] =
        date
        |> String.split(".")
        |> Enum.map(fn number -> String.to_integer(number) - 1 end)

      if month < 0 or month >= length(months()), do: throw(:month_range_error)
      month_data = Enum.at(months(), month)

      if day < 0 or day >= month_data.days_count, do: throw(:day_range_error)

      days_before_month =
        Enum.reduce_while(months(), 0, fn month, days ->
          if month_data.key == month.key,
            do: {:halt, days},
            else: {:cont, days + month.days_count}
        end)

      {:ok, from_days(year * @day_by_year + days_before_month + day)}
    rescue
      _ -> {:error, :format_error}
    catch
      reason -> {:error, reason}
    end
  end

  @doc """
  Create a calendar form a given string-format datequarter following the format `y.m.d q/4`.
  """
  @spec from_datequarter(String.t()) :: {:ok, Calendar.t()} | {:error, :atom}
  def from_datequarter(datequarter) when is_binary(datequarter) do
    try do
      [date, quarter] = String.split(datequarter, " ")
      [quarter, _] = String.split(quarter, "/")
      quarter = String.to_integer(quarter) - 1

      if quarter < 0 or quarter >= @quarter_by_day, do: throw(:quarter_range_error)

      case from_date(date) do
        {:ok, calendar} ->
          calendar = add(calendar, quarter, :quarter)
          {:ok, calendar}

        {:error, reason} ->
          {:error, reason}
      end
    rescue
      _ -> {:error, :format_error}
    catch
      reason -> {:error, reason}
    end
  end

  @doc """
  Create a calendar from a given number of days.
  The calendar will automatically starts at the beginning of a day (first quarter).
  """
  @spec from_days(integer) :: Calendar.t()
  def from_days(days) do
    new(days * 4 - 3)
  end

  @doc """
  Create a calendar from a given number of quarter.
  """
  @spec from_quarters(integer) :: Calendar.t()
  def from_quarters(quarters) do
    new(quarters)
  end

  @doc """
  Create string-format date following the format `y.m.d`.
  """
  @spec to_date(Calendar.t()) :: String.t()
  def to_date(%{} = calendar) do
    "#{calendar.year.number}.#{calendar.month.number}.#{calendar.month.day}"
  end

  @doc """
  Create string-format datequarter following the format `y.m.d q/4`.
  """
  @spec to_datequarter(Calendar.t()) :: String.t()
  def to_datequarter(%{} = calendar) do
    to_date(calendar) <> " #{calendar.quarter.number}/4"
  end

  @doc """
  Add a certain amount of [:year | :week | :day | :quarter] to a calendar.
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
  Move a calendar to the start of a certain calendar milestone.
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
  Move a calendar to the end of a certain calendar milestone.
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

  @doc """
  Return the months progression in percent.
  """
  @spec month_progression(Calendar.t()) :: float()
  def month_progression(%{month: %{day: day, days_count: days_count}}) do
    (day - 1) / (days_count - 1) * 100
  end

  @doc """
  Return the moon progression in percent where new moon equals 0% and full moon equals 100%.
  """
  @spec moon_progression(Calendar.t()) :: float()
  def moon_progression(%{moon: %{number: number}}) do
    [start_of_cycle, _, full_moon, end_of_cycle] = @moon_cycle_shift

    cond do
      number == start_of_cycle -> 0.0
      number == full_moon -> 100.0
      number < full_moon -> (number - 1) / (full_moon - start_of_cycle) * 100
      true -> (1.0 - (number - full_moon) / (end_of_cycle - full_moon + 1)) * 100
    end
  end

  @doc """
  Return the luminosity struct from a calendar.
  """
  @spec luminosity(Calendar.t()) :: map()
  def luminosity(%{quarter: %{luminosity: luminosity}, season: %{luminosity_shift: luminosity_shift}}) do
    real_luminosity = luminosity + luminosity_shift
    default = List.first(luminosity_values())

    luminosity_values()
    |> Enum.reverse()
    |> Enum.find(default, fn l -> real_luminosity >= l.threshold end)
  end

  # ####### #
  # Private #
  # ####### #

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
      %{key: :morning, name: "matinée", luminosity: 7, description: "entre 6h et 12h"},
      %{key: :day, name: "après-midi", luminosity: 10, description: "entre 12h et 18h"},
      %{key: :evening, name: "soirée", luminosity: 5, description: "entre 18h et minuit"},
      %{key: :night, name: "nuit", luminosity: 0, description: "entre minuit et 6h"}
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
      %{key: :spring, name: "printemps", luminosity_shift: -3},
      %{key: :summer, name: "été", luminosity_shift: 0},
      %{key: :fall, name: "automne", luminosity_shift: -3},
      %{key: :winter, name: "hivers", luminosity_shift: -5}
    ]
  end

  defp luminosity_values() do
    [
      %{key: :dark, name: "nuit noire", threshold: 0},
      %{key: :darkish, name: "sombre", threshold: 2},
      %{key: :ligthish, name: "clair", threshold: 4},
      %{key: :daylight, name: "jour", threshold: 5}
    ]
  end
end
