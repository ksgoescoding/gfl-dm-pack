# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     GfldmWeb.Repo.insert!(%GfldmWeb.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
use Bitwise

{:ok, server} = GfldmWeb.Servers.create_server(%{name: "Test Server", api_key: "api_key_123"})
{:ok, player} = GfldmWeb.Players.create_player(%{steamid: "[U:1:24408691]", server_id: server.id})
{:ok, pattern} = GfldmWeb.Tags.create_tag_pattern(%{name: "Pride", pattern: "e40303;ff8c00;ffed00;008026;004dff;750787", admin_flags: 1 <<< 14})
{:ok, tag} = GfldmWeb.Tags.create_tag(%{name: "Dreae", tag: "Dr.eae", default_pattern: pattern.id})
{:ok, _} = GfldmWeb.Tags.create_tag_override(%{player_id: player.id, tag_id: tag.id})
{:ok, _} = GfldmWeb.Tags.create_player_tag(%{player_id: player.id, tag_id: tag.id})
{:ok, _} = GfldmWeb.Tags.create_tag(%{name: "Admin", tag: "Admin", admin_flags: 1 <<< 1, default_tag_color: "4d7455"})
{:ok, _} = GfldmWeb.Tags.create_tag(%{name: "Super Admin", tag: "Super Admin", admin_flags: 1 <<< 6, default_tag_color: "b22222", default_name_color: "ffd700"})
{:ok, _} = GfldmWeb.Tags.create_tag(%{name: "Root", tag: "Root", admin_flags: 1 <<< 14, default_tag_color: "00bfff", default_name_color: "9932cc", default_chat_color: "f8f8ff"})
