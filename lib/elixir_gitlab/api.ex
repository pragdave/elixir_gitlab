defmodule ElixirGitlab.API do
  use GenServer

  require Logger

  @name __MODULE__

  @default_environment %{
    url_prefix:    Application.get_env(:elixir_gitlab, :url_prefix),
    private_token: Application.get_env(:elixir_gitlab, :private_token)
  }

  #######
  # API #
  #######

  def start_link() do
    GenServer.start_link(@name, @default_environment, name: @name)
  end

  def get(endpoint, options \\ []) do
    GenServer.call(@name, {:get, endpoint, options})
  end

  def post(endpoint, data, options \\ []) when is_list(data) do
    GenServer.call(@name, {:post, endpoint, {:form, data}, options})
  end

  def put(endpoint, data, options \\ []) when is_list(data) do
    GenServer.call(@name, {:put, endpoint, {:form, data}, options})
  end

  def delete(endpoint, options \\ []) do
    GenServer.call(@name, {:delete, endpoint, options})
  end

  # Just for testing
  def set_url_prefix(prefix) do
    GenServer.cast(@name, {:set_url_prefix, prefix})
  end

  ##################
  # Implementation #
  ##################

  def handle_call({:get, endpoint, options}, _from,  env) do
    call_server(endpoint, options, env, &HTTPoison.get/1)
  end

  def handle_call({:post, endpoint, data, options}, _from,  env) do
    call_server(endpoint, options, env, fn url -> HTTPoison.post(url, data) end)
  end
  
  def handle_call({:put, endpoint, data, options}, _from,  env) do
    call_server(endpoint, options, env, fn url -> HTTPoison.put(url, data) end)
  end
  
  def handle_call({:delete, endpoint, options}, _from,  env) do
    call_server(endpoint, options, env, &HTTPoison.delete/1)
  end

  # Only for testing
  def handle_cast({:set_url_prefix, prefix}, env) do
    { :noreply, Map.put(env, :url_prefix, prefix) }
  end

  ###########
  # Helpers #
  ###########

  def call_server(endpoint, options, env, http_fn) do
    with response = endpoint
                    |> to_url(options, env)
                    |> IO.inspect
                    |> http_fn.()
                    |> decode_response,
    do: { :reply, response, env }
  end

  def to_url(endpoint, options, %{ url_prefix: prefix, private_token: token }) do
    with full_opts = [ {:private_token, token} | options ],
    do:  "#{prefix}/#{endpoint}?#{encode_options(full_opts)}"
  end

  def encode_options([]) do
    ""
  end

  def encode_options(options) when is_list(options) do
    options
    |> Enum.map(fn {k,v} -> "#{k}=#{v}" end)
    |> Enum.join("&")
  end

  def decode_response({:ok, %{status_code: status, body: message}}) do
    cond do
      200 <= status and status < 300 ->
        { :ok, Poison.decode!(message, keys: :atoms) }
      400 <= status and status < 500 ->
        { :error, { status, message } }
      500 <= status and status < 600 ->
        { :server_error, message }
    end
  end
  

  def keys_to_atoms(list) when is_list(list) do
    list |> Enum.map(&keys_to_atoms/1)
  end

  def keys_to_atoms(map) when is_map(map) do
    map
    |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
    |> Enum.into(%{})
  end

end
