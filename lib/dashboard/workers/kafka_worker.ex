defmodule Monitor.KafkaWorker do
  use GenServer
  @me __MODULE__
  @kafka "Kafka"


  def start_link(opts) do
    IO.inspect("Kafka worker start_link/1")
    GenServer.start_link(@me, :ok, opts)
  end

  @impl true
  def init(:ok) do
    IO.inspect("Kafka worker init/ok")
    update_message(%{system: @kafka,status: :init, message: "Connecting..."})
    Process.send_after(self(), :refresh, 12000)
    {:ok, %{}}
  end

  @impl true
  def handle_call(:profile, _caller, state) do
    IO.inspect("KafkaWorker :profile handle_call/2")
    {:reply, state, state}
  end

  @impl true
  def handle_info(:refresh, _state) do
    IO.puts("KafkaWorker message received from Kafka")
    connect_kafka()
    Process.send_after(self(),:refresh, 30000)
    {:noreply, "_message"}
  end

  @impl true
  def handle_info(_, state) do
    IO.puts("KafkaWorker message received from Kafka")
    {:noreply, state}
  end

  defp connect_kafka() do
    case KafkaEx.create_worker(:si_worker) do
      {:ok, _pid} ->
        IO.inspect("********** KafkaWorker connect_kafa")
        response = KafkaEx.metadata(topic: "test", worker_name: :si_worker)
        metadata = response.topic_metadatas
        [head | _] = metadata
        IO.inspect(head)
        error_code = head.error_code
        IO.inspect(error_code)

        update_message(%{system: @kafka, status: :connected, message: "Connected successfully"})

      {:error,  %RuntimeError{message: err_message}}->
        IO.puts("Kafka RuntimeError error >>>>>>>")
        IO.inspect(err_message)
        update_message(%{system: @kafka, status: :error, message: err_message})
      {:error, reason} ->
        IO.puts("Unknown error >>>>>>>")
        IO.inspect(reason)
        {status, pid} = reason

        case status do
          :already_started ->
            IO.inspect("Worker has already started, assuming still connected")
            IO.inspect(pid)
            response = KafkaEx.metadata(topic: "test", worker_name: :si_worker)
            metadata = response.topic_metadatas
            [head | _tail] = metadata
            IO.inspect(head)
            error_code = head.error_code
            IO.inspect(error_code)
            update_message(%{system: @kafka, status: :connected, message: "Connected successfully!"})
          :econnrefused ->
            IO.inspect("Connection refused, Kafka is not reachable or not started yet")
            IO.inspect(pid)
            response = KafkaEx.metadata(topic: "test", worker_name: :si_worker)
            metadata = response.topic_metadatas
            [head | _tail] = metadata
            IO.inspect(head)
            error_code = head.error_code
            IO.inspect(error_code)
            update_message(%{system: @kafka, status: :error, message: "Connection refused"})
          _ ->
              IO.inspect("Unknown error, marking as connection error")
              update_message(%{system: @kafka, status: :error, message: "Connection lost, server down!!"})
        end
    end
  end

  defp update_message(message) do
    IO.inspect("Update_message with Manager")
    nd = NaiveDateTime.local_now()
    now = NaiveDateTime.to_string(nd)
    status = %{system: message.system, status: message.status, message: message.message, updated_at: now, image: "images/kafka.png"}
    Monitor.Manager.update_state(@me, status)
  end


  #DJdxBR67TrG_pqxx2Q8HBg
  # bin/kafka-storage.sh random-uuid
  # bin/kafka-storage.sh format -t DJdxBR67TrG_pqxx2Q8HBg -c config/kraft/server.properties
  # bin/kafka-server-start.sh config/kraft/server.properties


end
