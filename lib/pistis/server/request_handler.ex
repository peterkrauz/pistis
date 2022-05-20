defmodule Pistis.Server.RequestHandler do
  def process(message) do
    Pistis.Server.CommandRouter.route_message(message)
  end
end
