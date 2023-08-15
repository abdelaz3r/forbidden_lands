defmodule ForbiddenLands.CalendarTest do
  use ExUnit.Case

  alias ForbiddenLands.Calendar

  describe "from_date/1" do
    test "parses a valid date string into a calendar" do
      assert {:ok, calendar} = Calendar.from_date("1.4.1165")

      assert calendar.count.days == 424_997
      assert calendar.count.quarters == 1_699_985
      assert calendar.count.weeks == 60_714

      assert calendar.month.day == 1
      assert calendar.month.number == 4
      assert calendar.year.number == 1_165

      assert calendar.quarter.number == 1
      assert calendar.day.number == 6
      assert calendar.season.number == 2
      assert calendar.moon.number == 13
    end

    test "parses edge-cases date string into a calendar" do
      assert {:ok, calendar} = Calendar.from_date("1.1.1165")

      assert calendar.month.day == 1
      assert calendar.month.number == 1
      assert calendar.year.number == 1_165

      assert {:ok, calendar} = Calendar.from_date("45.1.1165")

      assert calendar.month.day == 45
      assert calendar.month.number == 1
      assert calendar.year.number == 1_165

      assert {:ok, calendar} = Calendar.from_date("46.8.1165")

      assert calendar.month.day == 46
      assert calendar.month.number == 8
      assert calendar.year.number == 1_165
    end

    test "returns an error tuple for an invalid date string" do
      assert {:error, :format_error} = Calendar.from_date("not_a_date_string")
      assert {:error, :format_error} = Calendar.from_date("6-0.1.11-65")
      assert {:error, :format_error} = Calendar.from_date("a.b.c")
    end

    test "returns an error tuple for a date string with an out-of-range day" do
      assert {:error, :day_range_error} = Calendar.from_date("60.1.1165")
      assert {:error, :day_range_error} = Calendar.from_date("-1.1.1165")
      assert {:error, :day_range_error} = Calendar.from_date("0.1.1165")
    end

    test "returns an error tuple for a date string with an out-of-range month" do
      assert {:error, :month_range_error} = Calendar.from_date("1.13.1165")
      assert {:error, :month_range_error} = Calendar.from_date("1.0.1165")
      assert {:error, :month_range_error} = Calendar.from_date("1.-1.1165")
    end

    test "returns an error tuple for a date string with an out-of-range year" do
      assert {:error, :year_range_error} = Calendar.from_date("60.1.-1165")
      assert {:error, :year_range_error} = Calendar.from_date("60.1.0")
    end

    test "test weird dates" do
      assert {:ok, _calendar} = Calendar.from_date("1.1.1")
      assert {:ok, _calendar} = Calendar.from_date("1.1.10000")
      assert {:ok, _calendar} = Calendar.from_date("1.1.1000000")
    end
  end

  describe "from_datequarter/1" do
    test "parses a valid datequarter string into a calendar" do
      assert {:ok, calendar} = Calendar.from_datequarter("1.4.1165 2/4")

      assert calendar.count.days == 424_997
      assert calendar.count.quarters == 1_699_986
      assert calendar.count.weeks == 60_714

      assert calendar.month.day == 1
      assert calendar.month.number == 4
      assert calendar.year.number == 1_165

      assert calendar.quarter.number == 2
      assert calendar.day.number == 6
      assert calendar.season.number == 2
      assert calendar.moon.number == 13
    end

    test "returns an error tuple for an invalid date string" do
      assert {:error, :format_error} = Calendar.from_datequarter("not_a_date_string")
      assert {:error, :format_error} = Calendar.from_datequarter("1.4.1165 3/5")
    end

    test "returns an error tuple for a date string with an out-of-range day" do
      assert {:error, :quarter_range_error} = Calendar.from_datequarter("1.4.1165 6/4")
      assert {:error, :quarter_range_error} = Calendar.from_datequarter("1.4.1165 -6/4")
    end
  end

  describe "from_days/1" do
    test "create a calendar from a number of days" do
      calendar = Calendar.from_days(424_997)

      assert calendar.count.days == 424_997
    end
  end

  describe "from_quarters/1" do
    test "create a calendar from a number of quarters" do
      calendar = Calendar.from_quarters(1_699_986)

      assert calendar.count.quarters == 1_699_986
    end
  end

  describe "to_date/1" do
    test "create a string representation of the calendar" do
      {:ok, calendar} = Calendar.from_date("1.4.1165")
      date = Calendar.to_date(calendar)

      assert date == "1.4.1165"
    end
  end

  describe "to_datequarter/1" do
    test "create a string representation of the calendar" do
      {:ok, calendar} = Calendar.from_datequarter("1.4.1165 3/4")
      date = Calendar.to_datequarter(calendar)

      assert date == "1.4.1165 3/4"
    end
  end

  describe "format/1" do
    test "create a string representation of the calendar" do
      {:ok, calendar} = Calendar.from_datequarter("1.4.1165 3/4")

      assert Calendar.format(calendar) == "1 summerwane 1165, evening"
      assert Calendar.format(calendar, :long) == "1 summerwane 1165, evening"
      assert Calendar.format(calendar, :short) == "1 summerwane 1165"
    end
  end

  describe "add/3" do
    test "manipulate a calendar" do
      {:ok, calendar} = Calendar.from_datequarter("1.4.1165 3/4")

      calendar = Calendar.add(calendar, 0, :day)
      assert Calendar.to_datequarter(calendar) == "1.4.1165 3/4"

      calendar = Calendar.add(calendar, 1, :day)
      assert Calendar.to_datequarter(calendar) == "2.4.1165 3/4"

      calendar = Calendar.add(calendar, -2, :day)
      assert Calendar.to_datequarter(calendar) == "46.3.1165 3/4"

      calendar = Calendar.add(calendar, 1, :day)
      assert Calendar.to_datequarter(calendar) == "1.4.1165 3/4"

      calendar = Calendar.add(calendar, 3, :quarter)
      assert Calendar.to_datequarter(calendar) == "2.4.1165 2/4"

      calendar = Calendar.add(calendar, 3, :week)
      assert Calendar.to_datequarter(calendar) == "23.4.1165 2/4"

      calendar = Calendar.add(calendar, 2, :year)
      assert Calendar.to_datequarter(calendar) == "23.4.1167 2/4"

      calendar = Calendar.add(calendar, -23, :day)
      assert Calendar.to_datequarter(calendar) == "46.3.1167 2/4"
    end

    test "manipulate a calendar (begining of a year)" do
      {:ok, calendar} = Calendar.from_datequarter("1.1.1165 1/4")

      calendar = Calendar.add(calendar, -1, :quarter)
      assert Calendar.to_datequarter(calendar) == "46.8.1164 4/4"
    end

    test "manipulate a calendar (ending of a year)" do
      {:ok, calendar} = Calendar.from_datequarter("46.8.1164 4/4")

      calendar = Calendar.add(calendar, 1, :quarter)
      assert Calendar.to_datequarter(calendar) == "1.1.1165 1/4"
    end
  end

  describe "start_of/2" do
    test "get to the begining of a time unit from a random date" do
      {:ok, calendar} = Calendar.from_datequarter("23.4.1165 3/4")

      assert calendar |> Calendar.start_of(:year) |> Calendar.to_datequarter() == "1.1.1165 1/4"
      assert calendar |> Calendar.start_of(:month) |> Calendar.to_datequarter() == "1.4.1165 1/4"
      assert Calendar.start_of(calendar, :week).day.number == 1
      assert calendar |> Calendar.start_of(:day) |> Calendar.to_datequarter() == "23.4.1165 1/4"
    end

    test "get to the begining of a time unit from the begining of a year" do
      {:ok, calendar} = Calendar.from_datequarter("1.1.1165 1/4")

      assert calendar |> Calendar.start_of(:year) |> Calendar.to_datequarter() == "1.1.1165 1/4"
      assert calendar |> Calendar.start_of(:month) |> Calendar.to_datequarter() == "1.1.1165 1/4"
      assert Calendar.start_of(calendar, :week).day.number == 1
      assert calendar |> Calendar.start_of(:day) |> Calendar.to_datequarter() == "1.1.1165 1/4"
    end

    test "get to the begining of a time unit from the ending of a year" do
      {:ok, calendar} = Calendar.from_datequarter("46.8.1165 4/4")

      assert calendar |> Calendar.start_of(:year) |> Calendar.to_datequarter() == "1.1.1165 1/4"
      assert calendar |> Calendar.start_of(:month) |> Calendar.to_datequarter() == "1.8.1165 1/4"
      assert Calendar.start_of(calendar, :week).day.number == 1
      assert calendar |> Calendar.start_of(:day) |> Calendar.to_datequarter() == "46.8.1165 1/4"
    end
  end

  describe "end_of/2" do
    test "get to the end of a time unit from a random date" do
      {:ok, calendar} = Calendar.from_datequarter("23.4.1165 3/4")

      assert calendar |> Calendar.end_of(:year) |> Calendar.to_datequarter() == "46.8.1165 4/4"
      assert calendar |> Calendar.end_of(:month) |> Calendar.to_datequarter() == "46.4.1165 4/4"
      assert Calendar.end_of(calendar, :week).day.number == 7
      assert calendar |> Calendar.end_of(:day) |> Calendar.to_datequarter() == "23.4.1165 4/4"
    end

    test "get to the end of a time unit from the begining of a year" do
      {:ok, calendar} = Calendar.from_datequarter("1.1.1165 1/4")

      assert calendar |> Calendar.end_of(:year) |> Calendar.to_datequarter() == "46.8.1165 4/4"
      assert calendar |> Calendar.end_of(:month) |> Calendar.to_datequarter() == "45.1.1165 4/4"
      assert Calendar.end_of(calendar, :week).day.number == 7
      assert calendar |> Calendar.end_of(:day) |> Calendar.to_datequarter() == "1.1.1165 4/4"
    end

    test "get to the end of a time unit from the ending of a year" do
      {:ok, calendar} = Calendar.from_datequarter("46.8.1165 4/4")

      assert calendar |> Calendar.end_of(:year) |> Calendar.to_datequarter() == "46.8.1165 4/4"
      assert calendar |> Calendar.end_of(:month) |> Calendar.to_datequarter() == "46.8.1165 4/4"
      assert Calendar.end_of(calendar, :week).day.number == 7
      assert calendar |> Calendar.end_of(:day) |> Calendar.to_datequarter() == "46.8.1165 4/4"
    end
  end
end
