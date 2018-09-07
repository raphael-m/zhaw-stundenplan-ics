defmodule SimpleServer.Router do
  use Plug.Router
  import Plug.Conn
  if Mix.env == :dev do
    use Plug.Debugger
  end
  require Logger

  plug(Plug.Logger, log: :debug)

  plug(:match)
  plug(:dispatch)

  # Return students calendar
  get "/v1/calendar/:student" do
      conn = Plug.Conn.put_resp_header(conn, "Content-Disposition", "attachment; filename=\"#{student}.ics\"")
      send_resp(conn, 200, ZHAW.Calendar.getCalendarFileContents(student))
  end

  # "Default" route that will get called when no other route is matched
  match _ do
      send_resp(conn, 404, "not found")
  end

end
