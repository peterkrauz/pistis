defmodule Pistis.Cluster.State do
  defstruct [:leader, :members, :failures]

  @type raft_member :: tuple()
  @type t :: %__MODULE__{
    leader: raft_member() | nil,
    members: list(raft_member()) | nil,
    failures: list(raft_member()) | nil,
  }

  @spec empty :: Pistis.Cluster.State.t()
  def empty(), do: %__MODULE__{}
end
