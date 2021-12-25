defmodule Monitor.Supervisor do
  use Supervisor

  def start_link(opts) do
    IO.inspect("Supervisor start_link/1")
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    IO.inspect("Supervisor init/ok")
    children = [
      {Monitor.Manager, [name: Monitor.Manager]},
      {Monitor.KafkaWorker, [name: Monitor.KafkaWorker]},
      {Monitor.ApiWorker, [name: Monitor.ApiWorker]}
     #{Monitor.MailWorker, [name: Monitor.MailWorker]}

    ]

  Supervisor.init(children, strategy: :one_for_one)
  end

end
