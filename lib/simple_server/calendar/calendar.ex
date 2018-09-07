defmodule ZHAW.Calendar do
  @moduledoc """
  Handles ZHAW calendar requests.
  """

  @apiUrl "https://api.apps.engineering.zhaw.ch/v1/schedules/students/"
  @userAgent System.get_env("ZHAW_API_UserAgent")

  def getCalendarFileContents(student) do
    use Timex
    now = Timex.now
    firstDate = Timex.beginning_of_week now

    # Because the api currently only supports returning 7 days per request,
    # take the following 24 weeks and combine the results (in a future version,
    # we'll take care of semesters etc.)
    events = 0..24
      |> Enum.map(fn w -> Timex.add(firstDate, Duration.from_days(7 * w)) end)
      |> Enum.map(fn d -> Timex.format!(d, "{ISOdate}") end)
      |> Enum.map(fn d -> getWeek(d, student) end)
      |> List.flatten

    EEx.eval_file "lib/simple_server/calendar/ics-template.eex", [events: events]

  end

  @doc """
  Return events for one week
  """
  defp getWeek(startingAt, student) do
    url = "#{@apiUrl}#{student}?startingAt=#{startingAt}&days=7"
    %{ body: body } = HTTPotion.get url, [ headers: [ "User-Agent": @userAgent, Accept: "application/json" ] ]
    body = body |> Poison.decode!

    case body do
      # If the body contents does not return events, return an empty list
      %{"message" => _} -> []
      _ ->  Enum.map(body["days"], fn d -> d["events"] end)
        |> List.flatten
    end
  end
end
