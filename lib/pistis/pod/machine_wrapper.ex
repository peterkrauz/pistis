defmodule Pistis.Pod.MachineWrapper do
  @behaviour :ra_machine

  @me __MODULE__
  @machine_config %{}
  @machine_module Application.fetch_env!(:pistis, :machine)
  @side_effects []

  @spec machine_spec :: {:module, Pistis.Pod.MachineWrapper, %{}}

  @impl :ra_machine
  def init(_config), do: @machine_module.initial_state()

  @impl :ra_machine
  def apply(_command_metadata, command, state) do
    result = @machine_module.process_command(command, state)
    {result.state, result.response, @side_effects}
  end

  def machine_spec(), do: {:module, @me, @machine_config}
end
