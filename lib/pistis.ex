defmodule Pistis do
  alias Pistis.Server.RequestHandler

  def put(key, value), do: RequestHandler.process({:put, key, value})
  def get(key), do: RequestHandler.process({:get, key})
  def data(), do: RequestHandler.process({:data})
end
