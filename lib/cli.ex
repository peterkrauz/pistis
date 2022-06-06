defmodule CLI do
  alias Pistis.Server

  def put(key, value), do: Server.send_request({:put, key, value})
  def get(key), do: Server.send_request({:get, key})
  def data(), do: Server.send_request({:data})

  def push(item), do: Server.send_request({:push, item})
  def pop(), do: Server.send_request({:pop})
  def peek(), do: Server.send_request({:peek})
end
