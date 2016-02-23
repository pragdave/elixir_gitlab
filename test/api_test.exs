defmodule ApiTest do
  use   ApiCase
  alias ElixirGitlab.API


  test "api can handle a normal response", %{bypass: bypass} do
    expect(bypass, "GET", "/fred",
           to_return(200, ~s<{"data": [{"first": 1, "second": 1}]}>))

    assert {:ok, %{data: [%{first: 1, second: 1}]}} == API.get("fred")
  end
  
  test "api can handle an error response", %{bypass: bypass} do
    expect(bypass, "GET", "/fred",
           to_return(404, ~s<not found. anywhere.>))

    assert {:error, {404, "not found. anywhere."}} == API.get("fred")
  end

  test "api can handle a post with no options", %{bypass: bypass} do
    expect(bypass, "POST", "/wilma",
           to_return(200, ~s<"post response">))

    assert {:ok, "post response"} == API.post("wilma", [])
  end
  
  test "api can handle a post with options", %{bypass: bypass} do
    expect(bypass, "POST", "/betty", "name=barney&age=23",
           to_return(200, ~s<"post response">))

    assert {:ok, "post response"} == API.post("betty", [name: "barney", age: 23])
  end
  
  test "api can handle a put with no options", %{bypass: bypass} do
    expect(bypass, "PUT", "/wilma",
           to_return(200, ~s<"put response">))

    assert {:ok, "put response"} == API.put("wilma", [])
  end
  
  test "api can handle a put with options", %{bypass: bypass} do
    expect(bypass, "PUT", "/betty", "name=barney&age=23",
           to_return(200, ~s<"put response">))

    assert {:ok, "put response"} == API.put("betty", [name: "barney", age: 23])
  end

  test "api can handle a delete", %{bypass: bypass} do
    expect(bypass, "DELETE", "/bambam",
           to_return(200, ~s<"all gone">))

    assert {:ok, "all gone"} == API.delete("bambam")
  end

end
