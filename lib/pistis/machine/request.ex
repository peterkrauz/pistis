defmodule Pistis.Machine.Request do
  defstruct [:body]
  @type t() :: %__MODULE__{body: any()}
end
