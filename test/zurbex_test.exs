defmodule ZurbexTest do
  use ExUnit.Case
  doctest Zurbex

  test "it returns html from slim template" do
    assert "<container><h1><elixir>Zurbex.Parser.my_gettext(\"Welcome %{name}\", name: name)</elixir></h1>" <> _ = Zurbex.Parser.slim_to_html("source/pages/newsletter")
  end
  
  test "it should parse elixir tags" do
    assert "<container><h1><%=Zurbex.Parser.my_gettext(\"Welcome %{name}\", name: name)%></h1>" <> _ = "source/pages/newsletter" 
    |> Zurbex.Parser.slim_to_html
    |> Zurbex.Parser.html_to_eex
  end
  
  test "final" do
    assert {"<container><h1>Welcome Jane</h1>" <> _, _} = "source/pages/newsletter" 
    |> Zurbex.Parser.slim_to_html
    |> Zurbex.Parser.html_to_eex
    |> Zurbex.Parser.eex_to_ast
    |> Code.eval_quoted(name: "Jane")
  end
  
  test "it should render a sample template" do
    assert ~S[<container><row><columns large="8"><h1>Hi there, Jane Doe</h1></columns></row></container>] = Zurbex.render_template(:sample, name: "Jane Doe")
  end
end
