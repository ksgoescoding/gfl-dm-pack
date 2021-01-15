defmodule GfldmWebWeb.ServerTagsChannel do
  use Phoenix.Channel

  def join("tags:" <> server_id, _params, socket) do
    IO.puts("Server #{server_id} joined")
    {:ok, socket}
  end

  def handle_in("load_tags", %{"steamid" => steamid}, socket) do
    case GfldmWeb.Tags.load_player_tag_config(steamid) do
      nil -> {:reply, :not_found, socket}
      player -> case resolve_tag_config(player) do
        nil -> {:reply, :not_found, socket}
        resolved -> {:reply, {:ok, resolved}, socket}
      end
    end
  end

  def handle_in("reset_tag", %{"steamid" => steamid} = params, socket) do
    case GfldmWeb.Tags.load_player_tag_config(steamid) do
      nil -> {:reply, :not_found, socket}
      %GfldmWeb.Players.Player{tag: nil} -> {:reply, :ok, socket}
      %{tag: tag} ->
        {:ok, _} = GfldmWeb.Tags.update_player_tag(tag, %{
          custom_tag: "",
          name_color: "",
          tag_color: "",
          chat_color: "",
          name_pattern_id: nil,
          tag_pattern_id: nil,
          chat_pattern_id: nil
        })
        handle_in("load_tags", params, socket)
    end
  end

  def handle_in("set_name_color", %{"steamid" => steamid, "name_color" => color}, socket) do
    case GfldmWeb.Tags.load_player_tag_config(steamid) do
      nil ->
        {:ok, player} = GfldmWeb.Players.create_player(%{steamid: steamid})
        {:ok, _} = GfldmWeb.Tags.create_player_tag(%{player_id: player.id, name_color: color})
        {:reply, {:ok, %{name_color: color}}, socket}
      %GfldmWeb.Players.Player{tag: nil} = player ->
        {:ok, _} = GfldmWeb.Tags.create_player_tag(%{player_id: player.id, name_color: color})
        {:reply, {:ok, %{name_color: color}}, socket}
      %GfldmWeb.Players.Player{tag: tag} ->
        {:ok, _} = GfldmWeb.Tags.update_player_tag(tag, %{name_color: color})
        {:reply, {:ok, %{name_color: color}}, socket}
    end
  end

  def resolve_tag_config(player) do
    config = case player do
      %GfldmWeb.Players.Player{tag: nil} -> nil
      %GfldmWeb.Players.Player{tag: tag} ->
        config = %GfldmWebWeb.ServerTags.TagConfig{}
        |> Map.put(:tag_color, blank?(tag.tag_color))
        |> Map.put(:name_color, blank?(tag.name_color))
        |> Map.put(:chat_color, blank?(tag.chat_color))
        |> Map.put(:custom_tag, blank?(tag.custom_tag))
        config = case tag do
          %GfldmWeb.Tags.PlayerTag{tag: nil} -> config
          %GfldmWeb.Tags.PlayerTag{tag: tag_preset} ->
            config = config
            |> Map.put(:tag, blank?(tag_preset.tag))
            |> Map.put(:default_tag_color, blank?(tag_preset.default_tag_color))
            |> Map.put(:default_name_color, blank?(tag_preset.default_name_color))
            |> Map.put(:default_chat_color, blank?(tag_preset.default_chat_color))

            case tag_preset do
              %{pattern: nil} -> Map.put(config, :default_tag_pattern, "")
              %{pattern: pattern} -> Map.put(config, :default_tag_pattern, pattern.pattern)
            end
        end

        config = case tag do
          %{tag_pattern: nil} -> config
          %{tag_pattern: %{pattern: pattern}} -> Map.put(config, :tag_pattern, pattern)
        end
        config = case tag do
          %{name_pattern: nil} -> config
          %{name_pattern: %{pattern: pattern}} -> Map.put(config, :name_pattern, pattern)
        end
        config = case tag do
          %{chat_pattern: nil} -> config
          %{chat_pattern: %{pattern: pattern}} -> Map.put(config, :chat_pattern, pattern)
        end

        config
    end

    config
  end

  defp blank?(nil), do: ""
  defp blank?(str), do: str
end
