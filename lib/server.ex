defmodule Workex.Server do
  @moduledoc """
    A gen_server based process which can be used to manipulate multiple workers and send 
    them messages. See readme for detailed description.
  """

  use ExActor
  
  def init(workex_args) do
    :folsom_metrics.new_spiral(:jobs)
    :folsom_metrics.new_counter(:job_counter)
    Enum.each(workex_args[:workers],fn(a) -> 
      #id = a[:worker][:id]
      id = a[:id]
      :folsom_metrics.new_counter(id)
      :folsom_metrics.tag_metric(id,:jobs) 
      queue_name = "#{id}_queue" |> binary_to_atom
      :folsom_metrics.new_counter(queue_name)
      :folsom_metrics.tag_metric(queue_name,:jobs)
      timer_name = binary_to_atom("#{id}_histogram")
      :folsom_metrics.new_histogram(timer_name,:slide_uniform,{60,1028})
      :folsom_metrics.tag_metric(timer_name,:jobs)
    end)
    initial_state(Workex.new(workex_args))
  end
  
  defcast push(worker_id, message), state: workex do
    :folsom_metrics.notify({:jobs,1})
    :folsom_metrics.notify({worker_id,{:inc,1}})
    :folsom_metrics.notify({:job_counter,{:inc, 1}})
    #IO.puts "#{inspect worker_id} count: #{:folsom_metrics.get_metric_value(:job_counter)} \n\t#{inspect :folsom_metrics.get_metric_value(:jobs)}"
    new_state(Workex.push(worker_id, message, workex))
  end
  
  def handle_info({:workex, msg}, workex), do: new_state(Workex.handle_message(msg, workex))
  def handle_info(_, workex), do: new_state(workex)
end
