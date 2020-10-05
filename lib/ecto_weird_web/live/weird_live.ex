defmodule EctoWeirdWeb.Inner do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :description, :string
    field :value, :string
  end

  def changeset(inner, params \\ %{}) do
    inner
    |> cast(params, [:value])
    |> validate_required([:value])
  end
end

defmodule EctoWeirdWeb.Outer do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :description, :string
    field :value, :string

    embeds_many :items, EctoWeirdWeb.Inner, on_replace: :delete
  end

  def changeset(outer, params \\ %{}) do
    outer
    |> cast(params, [:value])
    |> cast_embed(:items)
    |> validate_required([:value])
  end
end


defmodule EctoWeirdWeb.WeirdLive do
  use EctoWeirdWeb, :live_view
  alias EctoWeirdWeb.{Outer, Inner}

  @impl true
  def mount(_params, _session, socket) do
    data =
      %Outer{
        description: "Outer changeset",
        items: [
          %Inner{id: 1, description: "Item 1"},
          %Inner{id: 2, description: "Item 2"},
          %Inner{id: 3, description: "Item 3"},
        ]
      }
    changeset = Outer.changeset(data)
    {:ok,
     assign(socket,
      data: data,
      changeset: changeset
     )
    }
  end

  @impl true
  def handle_event("submit", %{"outer" => params}, socket) do
    IO.inspect(params)
    res = Outer.changeset(socket.assigns.data, params)
    IO.inspect(res)
    res = Ecto.Changeset.apply_action(res, :insert)

    s = case res do
          {:ok, data} ->
            IO.inspect(data)
            socket
          {:error, changeset} ->
            IO.inspect(changeset)
            assign(socket, changeset: changeset)
        end

    {:noreply, s}
  end

  def handle_event("test1", _params, socket) do
    params = %{
      "items" => %{
        "0" => %{"id" => "1", "value" => "a"},
        "1" => %{"id" => "2", "value" => "b"},
        "2" => %{"id" => "3", "value" => "c"}
      },
      "value" => ""
    }

    data =
      %Outer{
        description: "Outer changeset",
        items: [
          %Inner{id: 1, description: "Item 1"},
          %Inner{id: 2, description: "Item 2"},
          %Inner{id: 3, description: "Item 3"},
        ]
      }
    changeset = Outer.changeset(data, params)
    IO.inspect(changeset)
    {:noreply, socket}
  end

  def handle_event("test2", _params, socket) do
    params = %{
      "items" => %{
        "0" => %{"id" => "1", "value" => ""},
        "1" => %{"id" => "2", "value" => ""},
        "2" => %{"id" => "3", "value" => ""}
      },
      "value" => ""
    }

    data =
      %Outer{
        description: "Outer changeset",
        items: [
          %Inner{id: 1, description: "Item 1"},
          %Inner{id: 2, description: "Item 2"},
          %Inner{id: 3, description: "Item 3"},
        ]
      }
    changeset = Outer.changeset(data, params)
    IO.inspect(changeset)
    {:noreply, socket}
  end


  @impl true
  def render(assigns) do
    ~L"""
    <%= f = form_for @changeset, "#", [phx_submit: "submit"] %>
      <div><%= f.data.description %></div>
      <div><%= input_value f, :description %></div>
      <div>
        <%= label f, :value %>
        <%= text_input f, :value %>
        <%= error_tag f, :value %>
      </div>

      <table>
        <tbody>
          <%= for fi <- inputs_for f, :items do %>
          <tr>
            <td><%= fi.data.description %></td>
            <td><%= input_value fi, :description %></td>
            <td>
            <%= label fi, :value %>
            <%= text_input fi, :value %>
            <%= error_tag fi, :value %>
            <%= hidden_input fi, :id %>
            </td>
          </tr>
          <% end %>
        </tbody>
      </table>
      <button>Submit</button>
    </form>

    <button phx-click="test1">Test 1</button>
    <button phx-click="test2">Test 2</button>
    """
  end
end
