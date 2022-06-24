defmodule Pistis.Server do
  alias Pistis.Server.{ProcessCache, RequestHandler}

  def boot() do
    Pistis.Server.ProcessCache.boot()
  end

  def send_request(request_body) do
    ProcessCache.get_server_process()
    |> RequestHandler.send_request(request_body)
  end
end
