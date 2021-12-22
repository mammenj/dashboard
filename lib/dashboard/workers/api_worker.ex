defmodule Monitor.ApiWorker do
  use GenServer
  @me __MODULE__
  @api "API"

  def start_link(opts) do
    IO.inspect("ApiWorker worker start_link/1")
    GenServer.start_link(@me, :ok, opts)
  end

  @impl true
  def init(:ok) do
    IO.inspect("@@@@@@@@@@@ ApiWorker worker init/ok")
    update_message(%{system: @api, status: :init, message: "Connecting ..."})
    Process.send_after(self(), :refresh, 12000)
    {:ok, %{}}
  end

  @impl true
  def handle_call(:profile, _caller, state) do
    IO.inspect("ApiWorker :profile handle_call/2")
    {:reply, state, state}
  end

  @impl true
  def handle_info(:refresh, _state) do
    IO.puts("@@@@@@@@@@@@@@ ApiWorker message :refresh")
    HTTPoison.start()
    url = "https://jsonplaceholder.typicode.com/users/1"
    #---------
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        IO.inspect(body)
        response = Jason.decode!(body)
        new_state = Map.take(response, ["name"])

        value = new_state["name"]

        IO.inspect(new_state)
        update_message(%{system: @api, status: :connected, message: value})

        {:noreply, value}
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts("Not found error")
        update_message(%{system: @api, status: :error, message: "404 error"})
        {:noreply, nil}

      {:error, %HTTPoison.Error{reason: reason}} ->
          IO.puts("HTTP Error")
          update_message(%{system: @api, status: :error, message: reason})
          IO.inspect(reason)
          {:noreply, nil}

    end
    Process.send_after(self(),:refresh, 30000)
    #------------

    {:noreply, "_message"}
  end

  @impl true
  def handle_info(_, state) do
    IO.puts("ApiWorker message received")
    {:noreply, state}
  end


  defp update_message(message) do
    IO.inspect("ApiWorker Update_message with Manager")
    nd = NaiveDateTime.local_now()
    now = NaiveDateTime.to_string(nd)
    status =%{system: message.system, status: message.status, message: message.message, updated_at: now, image: "images/rest-api.png"}
    Monitor.Manager.update_state(@me, status)
  end
end
