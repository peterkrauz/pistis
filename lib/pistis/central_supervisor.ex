defmodule Pistis.CentralSupervisor do
  use DynamicSupervisor

  @me __MODULE__

  @type init_return :: %{
    extra_arguments: list,
    intensity: non_neg_integer,
    max_children: :infinity | non_neg_integer,
    period: pos_integer,
    strategy: :one_for_one
  }

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  @spec init(any) :: {:ok, init_return}
  @spec supervise(atom) :: any

  def start_link(init_arg \\ []) do
    IO.puts("CentralSupervisor: start_link")
    DynamicSupervisor.start_link(@me, init_arg, name: @me)
  end

  @impl DynamicSupervisor
  def init(_init_arg) do
    IO.puts("CentralSupervisor: init")
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def supervise(process_module) do
    case start_child(process_module) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  defp start_child(process_module) do
    DynamicSupervisor.start_child(@me, {process_module, []})
  end
end
