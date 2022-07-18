defmodule Pistis.Server.ProcessCache do
  use DynamicSupervisor
  use Pistis.Core.Journal
  alias Pistis.Server.NameRegistry

  @me __MODULE__

  def boot(), do: Pistis.Core.Supervisor.supervise(@me)

  def start_link(init_arg \\ []) do
    DynamicSupervisor.start_link(@me, init_arg, name: @me)
  end

  def init(_init_arg), do: DynamicSupervisor.init(strategy: :one_for_one)

  def get_server_process() do
    case start_child(NameRegistry.random_server_name()) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  defp start_child(server_name) do
    DynamicSupervisor.start_child(@me, {Pistis.Server.RequestHandler, server_name})
  end
end
