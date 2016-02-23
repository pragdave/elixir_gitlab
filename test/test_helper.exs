defmodule ApiCase do

  use ExUnit.CaseTemplate
  alias ElixirGitlab.API


  setup do
    with bypass = Bypass.open do
      API.set_url_prefix("http://localhost:#{bypass.port}")
      { :ok, bypass: bypass }
    end
  end


  ###########
  # Helpers #
  ###########

  using do
    quote do
  def expect(bypass, method, path, body \\ nil, returns) do
    Bypass.expect bypass, fn conn ->
      assert path == conn.request_path
      assert method == conn.method
      if body do
        with {:ok, request_body, _} = Plug.Conn.read_body(conn),
        do:  assert body == request_body
      end
      Plug.Conn.resp(conn, returns.code, returns.data)
    end
  end

  def to_return(code, data) do
    %{ code: code, data: data }
  end

  end
  end

end

ExUnit.start()
Application.ensure_all_started(:bypass)
