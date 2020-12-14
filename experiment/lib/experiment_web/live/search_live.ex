defmodule ExperimentWeb.SearchLive do
  use ExperimentWeb, :live_view

  alias Experiment.Stores

  def mount(_params, _sessions, socket) do
    socket = assign(socket, zip: "", stores: [], loading: false)
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <h1>Find a Store</h1>

    <form phx-submit="zip-search">
      <input type="text" name="zip" value="<%= @zip %>" placeholder="Enter Zip Code" autofocus autocomplete="off" <%= if @loading, do: "readonly" %> />
      <button type="submit">search</button>
    </form>

    <%= if @loading do %>
      <p>Loading ...</p>
    <% end %>

    <div id="search">
      <div class="stores">
        <ul>
          <%= for store <- @stores do %>
            <li>
              <div class="first-line">
                <div class="name">
                  <%= store.name %>
                </div>
                <div class="status">
                  <%= if store.open do %>
                    <span class="open">Open</span>
                  <% else %>
                    <span class="closed">Closed</span>
                  <% end %>
                </div>
              </div>
              <div class="second-line">
                <div class="street">
                  <%= store.street %>
                </div>
                <div class="phone_number">
                  <%= store.phone_number %>
                </div>
              </div>
            </li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  def handle_event("zip-search", %{"zip" => zip}, socket) do
    # Because the assign happen in sequence, first it start the Stores.search_by_zip(zip) and after that set loading to true, it will show both at the same time
    # To do async with the search, we are going to send ourself an internal message using send(self(), ...)
    # The message that we are sending for this case is an atom call :zip_search_loading and the zip value
    send(self(), {:zip_search_loading, zip})
    socket = assign(socket, zip: zip, stores: [], loading: true)
    {:noreply, socket}
  end

  # Since we are sending internal message to ourself in handle_event, we are going to use handle_info
  def handle_info({:zip_search_loading, zip}, socket) do
    case Stores.search_by_zip(zip) do
      [] ->
        socket =
          socket
          |> put_flash(:info, "No Stores matching")
          |> assign(stores: [], loading: false)

        {:noreply, socket}

      stores ->
        socket =
          socket
          |> clear_flash()
          |> assign(stores: stores, loading: false)

        {:noreply, socket}
    end
  end
end
