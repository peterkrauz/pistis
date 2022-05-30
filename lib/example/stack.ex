defmodule Example.Stack do
  @behaviour Pistis.Machine

  @impl Pistis.Machine
  def initial_state(), do: []

  @impl Pistis.Machine
  def process_command({:push, item}, state) do
    {:ok, [item | state]}
  end

  @impl Pistis.Machine
  def process_command({:pop}, []), do: {:empty_list, []}

  @impl Pistis.Machine
  def process_command({:pop}, state) do
    [head | tail] = state
    {head, tail}
  end

  @impl Pistis.Machine
  def process_command({:peek}, []), do: {:empty_list, []}

  @impl Pistis.Machine
  def process_command({:peek}, state) do
    [head | _] = state
    {head, state}
  end

end
