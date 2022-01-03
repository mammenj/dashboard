defmodule Monitor.Manager do
  use GenServer
  @me __MODULE__
  @topic "sys_status"

  def start_link(opts) do
    IO.inspect("Starting Manager start...start_link/1.")
    GenServer.start(@me, :ok, opts)
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Dashboard.PubSub, @topic)
  end

  def profile() do
    GenServer.call(@me, :profile)
  end

  def update_state(caller, key, status) do
    GenServer.cast(@me, {:update_and_merge, caller, key, status})
  end

  @impl true
  def init(:ok) do
    IO.inspect("Manager init/ok")
    {:ok, %{}}
  end

  @impl true
  def handle_call(:profile, __caller, state) do
    IO.puts("IN Manager profile00000000000")
    IO.inspect(state)
    IO.puts("IN Manager testprofile00000000000")
    {:reply, state, state}
  end


  @impl true
  def handle_cast({:update_and_merge, caller, key, data}, state) do
    IO.inspect("#{caller} state #{inspect(state)}  <<-------")
    IO.inspect("#{caller} merging #{inspect(data)}  <<-------")
    IO.inspect("#{caller} keykeykeykey #{inspect(key)}  <<-------")

    new_state =
      state
      |> Map.put(key, data)

    IO.inspect(new_state)
    broadcast_change({:ok, new_state}, :update)
    {:noreply, new_state}
  end

  @impl true
  def handle_info(:email, state) do
    #IO.inspect("Manager email handle info: #{state}")
    {:noreply, state}
  end

  @impl true
  def handle_info(_, state) do
    {:noreply, state}
  end

  defp broadcast_change({:ok, result}, event) do
    Phoenix.PubSub.broadcast(Dashboard.PubSub, @topic, {event, result})
    {:ok, result}
  end

end
