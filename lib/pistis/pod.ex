defmodule Pistis.Pod do
  def start() do
    :ra.start()

    # Pistis.CentralSupervisor.supervise(Pistis.Pod.Machine)

    # Also start some sort of health checker to
    # supervise this Node's Pistis.Pod.Machine
  end
end
