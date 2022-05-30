defmodule Pistis do
  alias Pistis.Server.RequestHandler

  def put(key, value), do: RequestHandler.process({:put, key, value})
  def get(key), do: RequestHandler.process({:get, key})
  def data(), do: RequestHandler.process({:data})

  def push(item), do: RequestHandler.process({:push, item})
  def pop(), do: RequestHandler.process({:pop})
  def peek(), do: RequestHandler.process({:peek})
end
