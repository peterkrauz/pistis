defmodule Pistis.CentralSupervisor do
  use Supervisor

  @me __MODULE__

  def start_link(init_arg), do: Supervisor.start_link(@me, init_arg, name: @me)

  @impl true
  def init(_init_arg) do
    children = [Pistis.Cluster.Loader, Pistis.DynamicSupervisor]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
