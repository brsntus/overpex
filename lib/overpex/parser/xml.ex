defmodule Overpex.Parser.XML do
  import SweetXml

  def parse(response) do
    osm = xpath(response, ~x"//osm")

    {:ok,
      %Overpex.Response{
        nodes:     parse_nodes(osm),
        ways:      parse_ways(osm),
        relations: parse_relations(osm)
    }}
  end

  defp parse_nodes(osm) do
    osm
    |> xpath(~x"./node"l)
    |> Enum.map(fn (node) ->
      %Overpex.Node{
        id:   node |> xpath(~x"./@id"i),
        lat:  node |> xpath(~x"./@lat"s) |> String.to_float(),
        lon:  node |> xpath(~x"./@lon"s) |> String.to_float(),
        tags: node |> parse_tags()
      }
    end)
  end

  defp parse_ways(osm) do
    osm
    |> xpath(~x"./way"l)
    |> Enum.map(fn (way) ->
      %Overpex.Way{
        id:    way |> xpath(~x"./@id"i),
        nodes: way |> xpath(~x"./nd"l)  |> Enum.map(fn (nd) -> nd |> xpath(~x"./@ref"i) end),
        tags:  way |> parse_tags()
      }
    end)
  end

  defp parse_relations(osm) do
    osm
    |> xpath(~x"./relation"l)
    |> Enum.map(fn (relation) ->
      %Overpex.Relation{
        id:      relation |> xpath(~x"./@id"i),
        members: relation |> parse_relation_members() ,
        tags:    relation |> parse_tags()
      }
    end)
  end

  defp parse_relation_members(collection) do
    collection
    |> xpath(~x"./member"l)
    |> Enum.map(&parse_relation_member/1)
  end

  defp parse_relation_member(member) do
    %Overpex.RelationMember{
      type: member |> xpath(~x"./@type"s),
      ref:  member |> xpath(~x"./@ref"i),
      role: member |> xpath(~x"./@role"s)
    }
  end

  defp parse_tags(collection) do
    collection
    |> xpath(~x"./tag"l)
    |> Enum.map(&parse_tag/1)
  end

  defp parse_tag(tag) do
    %Overpex.Tag{
      key:   xpath(tag, ~x"./@k"s),
      value: xpath(tag, ~x"./@v"s)
    }
  end
end
