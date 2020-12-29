defmodule ExperimentWeb.FilterLive do
  use ExperimentWeb, :live_view

  alias Experiment.Boats

  # first mount we grab all the boats from list_boats() function in Experiment.Boats
  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        boats: Boats.list_boats(),
        type: "",
        prices: []
      )

    # Temporary assigns are useful when you want to render some data and then discard it so LiveView no longer needs to keep it in memory.
    {:ok, socket, temporary_assigns: [boats: []]}
  end

  # options_for_select is a phoenix build if function that Returns options to be used inside a select.
  # for price_checkbox(), the other way is to make it a map like price_checkbox(%{price: price, checked: price in @price})
  def render(assigns) do
    ~L"""
      <form phx-change="filter">
        <select name="type">
          <%= options_for_select(type_options(), @type) %>
        </select>
        <div>
          <input type="hidden" name="prices[]" value="" />
          <%= for price <- ["$", "$$", "$$$"] do %>
            <%= price_checkbox(price: price, checked: price in @prices) %>
          <% end %>
        </div>
      </form>
      <ul>
      <%= for boat <- @boats do %>
        <li>
          <strong><%= boat.price %></strong> &mdash; <%= boat.model %> &ndash; <%= boat.type %>
        </li>
      <% end %>
      </ul>
    """
  end

  # update the boats using function list_boats according to the type and also update the type
  def handle_event("filter", %{"type" => type, "prices" => prices}, socket) do
    params = [type: type, prices: prices]
    boats = Boats.list_boats(params)
    socket = assign(socket, params ++ [boats: boats])
    {:noreply, socket}
  end

  # since the argument will be a key list, we need to put it in a map, using Enum.into, make assigns value into an empty map and put it into assign variable
  defp price_checkbox(assigns) do
    assigns = Enum.into(assigns, %{})

    ~L"""
    <input type="checkbox" id="<%= @price %>"
           name="prices[]" value="<%= @price %>"
           <%= if @checked, do: "checked" %>/>
    <label for="<%= @price %>"><%= @price %></label>
    """
  end

  defp type_options do
    [
      "All Types": "",
      Fishing: "fishing",
      Sporting: "sporting",
      Sailing: "sailing"
    ]
  end
end
