defmodule Workex.Throttler do
  def exec_and_measure(worker_id, fun) do
    {time, result} = :timer.tc(fun)
    timer_name = binary_to_atom("#{worker_id}_histogram")
    #IO.puts "#{timer_name} #{time} #{inspect fun}"
    :folsom_metrics.notify({timer_name,time})
    {round(time / 1000) + 1, result}
  end

  def throttle(worker_id,time, fun) do
    {exec_time, result} = exec_and_measure(worker_id,fun)
    do_throttle(time, exec_time)
    result
  end

  defp do_throttle(time, exec_time) when exec_time < time do
    :timer.sleep(time - exec_time)
  end

  defp do_throttle(_, _), do: :ok
end
