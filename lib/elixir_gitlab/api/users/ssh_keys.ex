defmodule ElixirGitlab.API.Users.SshKeys do

  alias  ElixirGitlab.API
  import ElixirGitlab.Util.Options
  import ElixirGitlab.Util.Into

  defmodule SshKey do
    defstruct [
     id:         -1,
     title:      "",
     key:        "",
     created_at: "",
    ]
  end



  def for_current_user do
    API.get("user/keys") |> into(SshKey)
  end

  def for_current_user_by_id(id) when is_integer(id) do
    API.get("user/keys/#{id}") |> into(SshKey)
  end

  def by_user_id(id) do
    API.get("users/#{id}/keys") |> into(SshKey)
  end

  @doc """
  Add an SSH key to the currently authenticated user
  """

  @add_to_options %{
    required: MapSet.new([:title, :key])
  }

  def add_to_current(options) do
    call_with_options(:post, "user/keys", options, @add_to_options)
    |> into(SshKey)
  end
  

  @doc """
  Add an ssh key for the user with a given id
  """

  def add_to_user(user_id, options) when is_integer(user_id) do
    call_with_options(:post, "users/#{user_id}/keys", options, @add_to_options)
    |> into(SshKey)
  end

  @doc """
  Delete an ssh key for the current user
  """

  def delete_for_current_user(key_id) when is_integer(key_id) do
    API.delete("user/keys/#{key_id}")
  end

  @doc """
  Delete an ssh key for a giver user
  """

  def delete_for_current_user(user_id, key_id)
  when is_integer(key_id) and is_integer(user_id) do
    API.delete("users/#{user_id}/keys/#{key_id}")
  end
end
