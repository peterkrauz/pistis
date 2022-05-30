defmodule Pistis.Application do
  @moduledoc false
  use Application

  @spec start(any, any) :: {:error, any} | {:ok, pid}

  @impl Application
  def start(_type, _args) do
    children = [Pistis.DynamicSupervisor]
    opts = [strategy: :one_for_one, name: Pistis.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
