defmodule Monitor.MailWorker do
  use GenServer
  @me __MODULE__

  def start_link(opts) do
    IO.inspect("MailWorker worker start_link/1")
    GenServer.start_link(@me, :ok, opts)
  end

  @impl true
  def init(:ok) do
    IO.inspect(" MailWorker worker init/ok")
    Process.send_after(self(), :send_email, 13000)
    {:ok, %{}}
  end

  @impl true
  def handle_info(:send_email, _state) do
    status_map = Monitor.Manager.profile()
    updated_state = get_error_status(status_map)
    IO.puts("MailWorker updated_state     +++++++++")
    IO.inspect(updated_state)

    case updated_state do
      nil ->
        IO.puts("NIL Case execute:: MailWorker updated_state +++++++++")
        IO.inspect(updated_state)
        {:noreply, updated_state}

      _ ->
        {:noreply, updated_state}
        IO.puts("NOT NIL Case execute:: MailWorker updated_state +++++++++")
        IO.inspect(updated_state)
        update_message(updated_state)
        {:noreply, updated_state}
    end
  end

  @impl true
  def handle_info(_, state) do
    IO.puts("Mailwork ???? message received from Kafka")
    {:noreply, state}
  end

  def send_mail(status) do
    Process.send_after(self(), :send_email, 31000)
    message = get_error_status(status)

    from_user = %{name: "JSM", email: "mammenj@live.com"}
    to_user = %{name: "JSM", email: "mammenj@gmail.com"}

    if message != nil do
      msg = message

      email_sent = msg["email_sent"]
      if email_sent === nil do
        email = Monitor.MyMail.send(from_user, msg, to_user)
        IO.puts(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>MOCKED EMAIL MailWorker.....")
        IO.inspect(email)
        nd1 = NaiveDateTime.local_now()
        now1 = NaiveDateTime.to_string(nd1)
        Map.merge(msg, %{email_sent: now1})
      end
    end
  end

  defp get_error_status(state) do
    IO.inspect("get_error_status  ----state------get_error_status")
    IO.inspect(state)

    new_map =
      Enum.find(state, fn {_, v} ->
        email_sent = v["email_sent"]
        status = v[:status]
        ######
        IO.inspect(email_sent)
        IO.inspect(status)

        case {email_sent, status} do
          _ when email_sent === nil and status === :error ->
            IO.inspect("trueeeeeeeeeeeeeeeee")
            IO.inspect(v.system)
            v

          _ ->
            nil
        end
      end)

    new_state =
      if new_map !== nil do
        {_, mystate} = new_map
        mystate
      end

    IO.inspect("-------------begin new map----------MailWorker----")
    IO.inspect(new_state)
    IO.inspect("-------------end new map----------------MailWorker")
    new_state
  end

  defp update_message(message) do
    IO.inspect("Update_message with Manager MailWorker")
    nd = NaiveDateTime.local_now()
    now = NaiveDateTime.to_string(nd)
    current_state = Monitor.Manager.profile()

    for key_status <- current_state do
      {key, updated_status} = key_status
      IO.inspect("Update_message with Manager.....")
      IO.inspect(updated_status)

      new_message =
        Map.merge(updated_status, %{
          system: message.system,
          status: message.status,
          message: message.message,
          email_sent: now
        })

      Monitor.Manager.update_state(@me, key, new_message)
    end
  end
end
