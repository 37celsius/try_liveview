defmodule ExperimentWeb.SalesDashboardLive do
  use ExperimentWeb, :live_view

  # At the moment we just do Enum.random() from experiment/sales.ex
  alias Experiment.Sales

  def mount(_params, _sessions, socket) do
    # Need to be careful here, because mount is invoke twice, so we put a guard clause return true if the socket is connected
    # At this stage we just do timer interval

    if connected?(socket) do
      # take time in milisecond, the pid we want to send message to which in this case it self, and the message which we name it :tick
      :timer.send_interval(1000, self(), :tick)
    end

    {:ok, assign_stats(socket)}
  end

  def render(assigns) do
    ~L"""
      <h1>Sales Dashboard</h1>
      <div id="dashboard">
        <div class="stats">
          <div class="stat">
            <span class="value">
              <%= @new_orders %>
            </span>
            <span class="name">
              New Orders
            </span>
          </div>
          <div class="stat">
            <span class="value">
              $<%= @sales_amount %>
            </span>
            <span class="name">
              Sales Amount
            </span>
          </div>
          <div class="stat">
            <span class="value">
              <%= @satisfaction %>%
            </span>
            <span class="name">
              Satisfaction
            </span>
          </div>
        </div>
        <button phx-click="refresh">
          Refresh
        </button>
      </div>
    """
  end

  def handle_event("refresh", _, socket) do
    {:noreply, assign_stats(socket)}
  end

  def handle_info(:tick, socket) do
    {:noreply, assign_stats(socket)}
  end

  defp assign_stats(socket) do
    assign(
      socket,
      new_orders: Sales.new_orders(),
      sales_amount: Sales.sales_amount(),
      satisfaction: Sales.satisfaction()
    )
  end
end
