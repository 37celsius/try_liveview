defmodule ExperimentWeb.LightLive do
  use ExperimentWeb, :live_view

  # Mount callback is the first one invoke
  # params = map containing query parameters as well as any router params
  # session = contain private session data
  # socket = contain a struct

  def mount(_params, _session, socket) do
    # IO.inspect(assign(socket, :brightness, 50))
    # below is assign a value of brightness to 50 as initial state
    {:ok, assign(socket, :brightness, 50)}
  end

  # assigns is from the function assign() in mount
  def render(assigns) do
    ~L"""
      <h1>Change the number</h1>
      <div><%= @brightness %></div>
      <button phx-click="max-button">make it 100</button>
      <button phx-click="min">minus 10</button>
      <button phx-click="add">add 10</button>
      <button phx-click="min-button">make it 0</button>
    """
  end

  # handle_event callback is from LiveView
  # takes 3 arguments
  # 1 is the name of the event
  # 2 is some metadata related to the event
  # 3 is the socket that has the current state of our LiveView process assigned to it

  def handle_event("max-button", _, socket) do
    {:noreply, assign(socket, :brightness, 100)}
  end

  def handle_event("min-button", _, socket) do
    {:noreply, assign(socket, :brightness, 0)}
  end

  def handle_event("min", _, socket) do
    {:noreply, update(socket, :brightness, &max(&1 - 10, 0))}
  end

  def handle_event("add", _, socket) do
    {:noreply, update(socket, :brightness, &min(&1 + 10, 100))}
  end
end
