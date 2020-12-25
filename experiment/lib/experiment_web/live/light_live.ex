defmodule ExperimentWeb.LightLive do
  use ExperimentWeb, :live_view

  use Timex

  # Mount callback is the first one invoke
  # params = map containing query parameters as well as any router params
  # session = contain private session data
  # socket = contain a struct

  def mount(_params, _session, socket) do
    # introducing timer
    if connected?(socket) do
      :timer.send_interval(1000, self(), :tick)
    end

    # introducing timer, Timex is a dependencies https://hexdocs.pm/timex/getting-started.html
    # below code, from Timex, grab time now, shift one hour, ie 12:30 becomes 13:30
    expiration_time = Timex.shift(Timex.now(), hours: 1)

    # IO.inspect(assign(socket, :brightness, 50))
    # below is assign a value of brightness to 50 as initial state
    # with time_remaining, we put from expiration_time ie: 13:30 and do Timex.diff(13:30, 12:30)
    {:ok,
     assign(socket,
       brightness: 50,
       expiration_time: expiration_time,
       time_remaining: time_remaining(expiration_time),
       tempr: 3000
     )}
  end

  # assigns is from the function assign() in mount
  def render(assigns) do
    ~L"""
      <h1>Change the number</h1>
      <p class="m-4 font-semibold text-indigo-800">
        <%= if @time_remaining > 0 do %>
          <%= format_time(@time_remaining) %> left to play with brightness
        <% else %>
          stop looking at the monitor and go outside
        <% end %>
      </p>
      <div><%= @brightness %></div>
      <form phx-change="slider-brightness">
        <input type="range" name="brightnessupdate" min="0" max="100" value="<%= @brightness %>" >
      </form>
      <button phx-click="max-button">make it 100</button>
      <button phx-click="min">minus 10</button>
      <button phx-click="add">add 10</button>
      <button phx-click="min-button">make it 0</button>

      <div>
        <p>Current Light Temprature: <%= @tempr %> and the color code is: <%= temp_color(@tempr) %></p>
      </div>

      <form phx-change="tempr-change">
        <input type="hidden" value="" name="tempr" />
        <%= for temp <- [3000, 4000, 5000] do %>
          <%= temp_radio_button(%{temp: temp, checked: temp == @tempr}) %>
        <% end %>
      </form>
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

  # using the second argument we capture the value in map
  def handle_event("slider-brightness", %{"brightnessupdate" => brightnessupdate}, socket) do
    brightness = String.to_integer(brightnessupdate)
    {:noreply, assign(socket, brightness: brightness)}
  end

  def handle_event("tempr-change", %{"tempr" => tempr}, socket) do
    tempr = String.to_integer(tempr)
    {:noreply, assign(socket, tempr: tempr)}
  end

  def handle_info(:tick, socket) do
    # capture the expiration_time from the socket.assigns
    expiration_time = socket.assigns.expiration_time

    # update the time remaining with inputing the captured expiration_time from the socket
    {:noreply, assign(socket, time_remaining: time_remaining(expiration_time))}
  end

  defp time_remaining(expiration_time) do
    # diff(datetime1, datetime2, unit \\ :second)
    # subtracts datetime2 from datetime1
    # below case, get time now and subtract from whatever the expiration_time is
    DateTime.diff(expiration_time, Timex.now())
  end

  defp format_time(time) do
    time
    |> Timex.Duration.from_seconds()
    |> Timex.format_duration(:humanized)
  end

  # Anytime you have LiveView template like the below expect variable call "assigns" that is a map
  defp temp_radio_button(assigns) do
    ~L"""
      <input type="radio" id="<%= @temp %>" name="tempr" value="<%= @temp %>" <%= if @checked, do: "checked" %> />
      <label for="<%= @temp %>"><%= @temp %></label>
    """
  end

  defp temp_color(3000), do: "#F1C40D"
  defp temp_color(4000), do: "#FEFF66"
  defp temp_color(5000), do: "#99CCFF"
end
