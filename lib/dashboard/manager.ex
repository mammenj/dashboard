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

  def update_state(caller, status) do
    # send_mail(status)

    GenServer.cast(@me, {:update_and_merge, caller, status})

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
  def handle_cast({:update_and_merge, caller, data}, state) do
    IO.inspect("#{caller} merging #{inspect(data)}  <<-------------")

    new_state =
      state
      |> Map.put(data.system, data)

    send_mail(new_state)
    broadcast_change({:ok, new_state}, :update)
    {:noreply, new_state}
  end

  @impl true
  def handle_info(:email, state) do
    IO.inspect("Manager email handle info: #{state}")
    {:noreply, state}
  end

  @impl true
  def handle_info(_, state) do
    IO.inspect("Manager handle info: #{state}")
    {:noreply, state}
  end

  defp broadcast_change({:ok, result}, event) do
    Phoenix.PubSub.broadcast(Dashboard.PubSub, @topic, {event, result})
    {:ok, result}
  end

  def send_mail(status) do
    message = get_error_status(status)
    IO.inspect("-----------Message ----send_mail------")
    IO.inspect(message)
    from_user = %{name: "JSM", email: "mammenj@live.com"}
    to_user = %{name: "JSM", email: "mammenj@gmail.com"}

    if message != nil do
      {_, msg} = message

      email_sent = msg["email_sent"]
      IO.inspect("this is the message...email_sent.............??????????")
      IO.inspect(email_sent)

      if email_sent == nil do
        email = Monitor.MyMail.send(from_user, msg, to_user)

        IO.puts(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>MOCKED EMAIL.....")
        IO.inspect(email)
        # {:ok, term} = Monitor.MyMailer.deliver(email)
        # IO.inspect(term)
        nd1 = NaiveDateTime.local_now()
        now1 = NaiveDateTime.to_string(nd1)
        new_message = Map.merge(msg, %{email_sent: now1})
        IO.puts("################# new state.....")
        IO.inspect(new_message)
        Monitor.Manager.update_state(@me, new_message)
      end
    end
  end

  defp get_error_status(state) do
    IO.inspect("Filtering  ----v------")
    new_map =
      Enum.find(state, fn {_, v} ->
        if v.status == :error and v["email_sent"] == nil do
          v
        end
      end
      )

    IO.inspect("-------------begin new map--------------")
    IO.inspect(new_map)
    IO.inspect("-------------end new map----------------")
    new_map
  end
end
