defmodule Workex.Worker do
  use ExActor
  
  defrecord State, [:id, :queue_pid, :job, :state] do
    import Workex.RecordHelper

    defoverridable [new: 1]
    def new(data) do
      super(data) |> notify_parent
    end

    defp notify_parent(this([queue_pid, id])) do
      queue_pid <- {:workex, {:worker_created, id, self}}
      this
    end

    def exec_job(messages, this([id, queue_pid, job, state])) do
      queue_name = binary_to_atom("#{id}_queue")
      msg_count = Enum.count messages
      :folsom_metrics.notify({queue_name,{:inc,msg_count}})
      new_state = job.(messages, state)
      :folsom_metrics.notify({queue_name,{:dec,msg_count}})
      queue_pid <- {:workex, {:worker_available, id}}
      this.state(new_state)
    end
  end
  
  def init(args) do
    initial_state(State.new(args))
  end
  
  defcast process(messages), state: state do
    new_state(state.exec_job(messages))
  end
end
