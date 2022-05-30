defmodule Pistis.Machine do

  @callback initial_state() :: any()
  @callback process_command(tuple(), any()) :: tuple()

end
