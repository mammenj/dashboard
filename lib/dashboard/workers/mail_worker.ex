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
    Process.send_after(self(), :send_email, 31000)
    {:ok, %{}}
  end




  @impl true
  def handle_info(:send_email, _state) do
    status_map = Monitor.Manager.profile()
    IO.puts("MailWorker send_email state message received send_email+++++++++")
    IO.inspect(status_map)
    IO.puts("+++++++++++MailWorker send_email state message received send_email")
    send_mail(status_map)
    #message = get_error_status(status_map)
    #IO.inspect(">>>>>>>>>>>>>>> Error message #{message}")
    Process.send_after(self(), :send_email, 31000)
    {:noreply, status_map}
  end


  def send_mail(status) do
    message = get_error_status(status)
    IO.inspect("MailWorker-----------Message ----send_mail------")
    IO.inspect(message)
    from_user = %{name: "JSM", email: "mammenj@live.com"}
    to_user = %{name: "JSM", email: "mammenj@gmail.com"}

    if message != nil do
      msg = message

      email_sent = msg["email_sent"]
      IO.inspect("MailWorker this is the message...email_sent.............??????????")
      IO.inspect(email_sent)

      if email_sent === nil do
        email = Monitor.MyMail.send(from_user, msg, to_user)
        IO.puts(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>MOCKED EMAIL MailWorker.....")
        IO.inspect(email)
        # {:ok, term} = Monitor.MyMailer.deliver(email)
        # IO.inspect(term)
        nd1 = NaiveDateTime.local_now()
        now1 = NaiveDateTime.to_string(nd1)
        new_message = Map.merge(msg, %{email_sent: now1})
        #update_message({key, new_message})
        update_message(new_message)
      end
    end
  end

  defp get_error_status(state) do
    IO.inspect("Filtering  ----state------MailWorker")
    IO.inspect(state)
    new_map =
      Enum.find(state, fn {_, v} ->
        IO.inspect(v)
        IO.inspect(v["email_sent"])
        if v["status"] === :error and v["email_sent"] === nil do
          IO.inspect("Foound a match 000000000000000000000000000")
          v
        end
      end
      )
      # Enum.find(state, fn {_, v} ->
      #   if v.status === :error and v["email_sent"] === nil do
      #     v
      #   end
      # end
      # )
    state = if new_map != nil do
      {_, mystate} = new_map
      mystate
    end


    IO.inspect("-------------begin new map----------MailWorker----")
    IO.inspect(state)
    IO.inspect("-------------end new map----------------MailWorker")
    state
  end

  defp update_message(message) do

    nd = NaiveDateTime.local_now()
    _now = NaiveDateTime.to_string(nd)
    IO.inspect("################MailWorker Update_message with Manager ####")
    IO.inspect(message)
    data_list = [{message.system, message}]
    Monitor.Manager.update_state(@me, data_list)
  end
end
