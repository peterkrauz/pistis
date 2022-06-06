defmodule Pistis.Machine do
  @type machine_state :: any()
  @callback initial_state() :: machine_state()
  @callback process_command(Pistis.Request.t(), machine_state()) :: Pistis.Response.t()
end
