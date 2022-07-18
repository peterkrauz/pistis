defmodule Pistis.Cluster.Spawner do
  alias Pistis.Cluster

  def spawn_nodes(node_count) do
    build_local_addresses(node_count)
    |> Enum.map(&Task.async(fn -> spawn_node(&1) end))
    |> Enum.map(&Task.await(&1))
  end

  defp build_local_addresses(node_count) do
    Range.new(1, node_count) |> Enum.map(fn index -> :"pistis_node_#{index}@127.0.0.1" end)
  end

  defp spawn_node(node_host) do
    {:ok, node} = :slave.start(to_charlist("127.0.0.1"), Cluster.node_name(node_host), inet_loader_args())
    add_code_paths(node)
    transfer_configuration(node)
    ensure_applications_started(node)
    {:ok, node}
  end

  defp inet_loader_args() do
    to_charlist("-loader inet -hosts 127.0.0.1 -setcookie #{:erlang.get_cookie()}")
  end

  defp add_code_paths(node) do
    rpc(node, :code, :add_paths, [:code.get_path()])
  end

  defp transfer_configuration(node) do
    for {app_name, _, _} <- Application.loaded_applications() do
      for {key, val} <- Application.get_all_env(app_name) do
        rpc(node, Application, :put_env, [app_name, key, val])
      end
    end
  end

  defp ensure_applications_started(node) do
    rpc(node, Application, :ensure_all_started, [:mix])
    rpc(node, Mix, :env, [Mix.env()])
    for {app_name, _, _} <- Application.loaded_applications() do
      rpc(node, Application, :ensure_all_started, [app_name])
    end
  end

  defp rpc(node, module, function, args) do
    :rpc.block_call(node, module, function, args)
  end
end
