defmodule DashboardWeb.MonitorLive do
  use DashboardWeb, :live_view

    def mount(_params, _session, socket) do
      if connected?(socket), do: Monitor.Manager.subscribe()
      {:ok, fetch(socket)}
    end

    defp fetch(socket) do
      results = Monitor.Manager.profile()

      assign(socket, :statuses, results)
    end

    @spec render(any) :: Phoenix.LiveView.Rendered.t()
    def render(assigns) do
      ~L"""
      <div>
      <%= for key_status <- @statuses do %>
      <% {_, status} = key_status %>
          <div class="row">
          <h2><%=status.system %> Status Light</h2>
            <div class="column">
              <img src= <%=status.image %> height=100 width=100>
            </div>
            <div class="column">
              <b>Status:</b> <%=status.status %>
              &nbsp;<br>
              <b>Details:</b> <%=status.message %>
              &nbsp;<br>
              <b>Updated:</b> <%=status.updated_at %>
              &nbsp;<br>
              <b>Sent email:</b> <%=status["email_sent"] %>
            </div>
            <div class="column">
              <%= case status.status do %>
                <% :connected -> %>
                <img src="images/traffic-green.svg" height=100 width=100>
                <% :error -> %>
                <img src="images/traffic-red.svg" height=100 width=100>
                <% :init -> %>
                <img src="images/traffic-yellow.svg" height=100 width=100>
                <% _ -> %>
                <img src="images/traffic-red.svg" height=100 width=100>
              <% end %>
            </div>

          </div>
          <hr width="100%">
      <% end %>
      </div>
      """
    end


    def handle_info({:update,results}, socket) do
      IO.inspect("----------Receiving Kafka Update..........")
      socket = assign(socket, :statuses, results )
      {:noreply, socket}
    end

    def handle_info({:api_update,results}, socket) do
      IO.inspect("----------Receiving API Update..........")
      socket = assign(socket, :statuses, results )
      {:noreply, socket}
    end


    def handle_info({_,results}, socket) do
      IO.inspect("Error Receiving Kafka Update..........")
      socket = assign(socket, :statuses, results )
      IO.inspect(results)
      {:noreply, socket}
    end
  end
