defmodule ZurbexTest do
  use ExUnit.Case

#  test "it returns html from slim template" do
#    assert "<container><h1><eex>gettext(\"Welcome %{name}\", name: @name)</eex></h1>" <> _ = Zurbex.Parser.slim_to_html("source/pages/newsletter")
#  end
#  
#  test "it should parse elixir tags" do
#    assert "<container><h1><%=gettext(\"Welcome %{name}\", name: @name)%></h1>" <> _ = "source/pages/newsletter" 
#    |> Zurbex.Parser.slim_to_html
#    |> Zurbex.Parser.html_to_eex
#  end
#  
#  test "it should render a sample template" do
#    assert Zurbex.render(:sample, name: "Jane Doe") =~ ~S[<h1 style="Margin:0;Margin-bottom:10px;color:inherit;font-family:Helvetica,Arial,sans-serif;font-size:34px;font-weight:400;line-height:1.3;margin:0;margin-bottom:10px;padding:0;text-align:left;word-wrap:normal">Hi there, Jane Doe</h1>] 
#  end
end
