defmodule ElixirGitlab.API.Users do

  alias  ElixirGitlab.API
  import ElixirGitlab.Util.Options
  import ElixirGitlab.Util.Into

  defmodule GitLabUser do
    defstruct [
     id:         -1,
     username:   "",
     email:      "",
     name:       "",
     state:      "",
     created_at: "",
     bio:        nil,
     skype:      "",
     linkedin:   "",
     twitter:    "",
     website_url: "",
     extern_uid:  "",
     provider:    "",
     theme_id:    -1,
     color_scheme_id:    -1,
     is_admin:           false,
     avatar_url:         "",
     can_create_group:   false,
     can_create_project:   false,
     current_sign_in_at: nil,
     two_factor_enabled: false,
     identities: nil,
     projects_limit: 0,
     web_url: nil,
    ]
  end


  def current do
    API.get("user") |> into(GitLabUser)
  end

  @all_opts %{
    required: MapSet.new(),
    optional: MapSet.new([ :search, :username ])
  }

  def all(options \\ []) do
    call_with_options(:get, "users", options, @all_opts) |> into(GitLabUser)
  end


  def by_id(id) when is_integer(id) do
    API.get("users/#{id}") |> into(GitLabUser)
  end

  @create_opts %{
    required: MapSet.new([ :email, :name, :password, :username ]),
    optional: MapSet.new([ :admin, :bio, :can_create_group, :confirm,
                           :extern_uid, :linkedin, :projects_limit,
                           :provider, :skype, :twitter, :website_url ])
  }

  def create(options) when is_list(options) do
    call_with_options(:post, "users", options, @create_opts) |> into(GitLabUser)
  end


  @doc """

  Deletes a user. Available only for administrators. This is an
  idempotent function, calling this function for a non-existent user
  id still returns a status code 200 OK. The JSON response differs if
  the user was actually deleted or not. In the former the user is
  returned and in the latter not.

  """

  def delete_by_id(id) when is_integer(id) do
    API.delete("users/#{id}") |> into(GitLabUser)
  end

  @doc """
  Update an existing user.
  """

  @update_opts %{
    optional: MapSet.new([:admin, :bio, :can_create_group,:can_create_project,
                          :email, :extern_uid, :linkedin, :name, :password,
                          :projects_limit, :provider, :skype, :twitter,
                          :username, :website_url])
  }


  def update(id, options) when is_integer(id) and is_list(options) do
    call_with_options(:put, "users/#{id}", options, @update_opts) |> into(GitLabUser)
  end




  ###########
  # Helpers #
  ###########


end


# Gets currently authenticated user.
# 
# GET /user
# {
#   "id": 1,
#   "username": "john_smith",
#   "email": "john@example.com",
#   "name": "John Smith",
#   "private_token": "dd34asd13as",
#   "state": "active",
#   "created_at": "2012-05-23T08:00:58Z",
#   "bio": null,
#   "skype": "",
#   "linkedin": "",
#   "twitter": "",
#   "website_url": "",
#   "theme_id": 1,
#   "color_scheme_id": 2,
#   "is_admin": false,
#   "can_create_group": true,
#   "can_create_project": true,
#   "projects_limit": 100
# }
# List SSH keys
# 
# Get a list of currently authenticated user's SSH keys.
# 
# GET /user/keys
# [
#   {
#     "id": 1,
#     "title": "Public key",
#     "key": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAIEAiPWx6WM4lhHNedGfBpPJNPpZ7yKu+dnn1SJejgt4596k6YjzGGphH2TUxwKzxcKDKKezwkpfnxPkSMkuEspGRt/aZZ9wa++Oi7Qkr8prgHc4soW6NUlfDzpvZK2H5E7eQaSeP3SAwGmQKUFHCddNaP0L+hM7zhFNzjFvpaMgJw0=",
#     "created_at": "2014-08-01T14:47:39.080Z"
#   },
#   {
#     "id": 3,
#     "title": "Another Public key",
#     "key": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAIEAiPWx6WM4lhHNedGfBpPJNPpZ7yKu+dnn1SJejgt4596k6YjzGGphH2TUxwKzxcKDKKezwkpfnxPkSMkuEspGRt/aZZ9wa++Oi7Qkr8prgHc4soW6NUlfDzpvZK2H5E7eQaSeP3SAwGmQKUFHCddNaP0L+hM7zhFNzjFvpaMgJw0=",
#     "created_at": "2014-08-01T14:47:39.080Z"
#   }
# ]
# Parameters:
# 
# none
# List SSH keys for user
# 
# Get a list of a specified user's SSH keys. Available only for admin
# 
# GET /users/:uid/keys
# Parameters:
# 
# uid (required) - id of specified user
# Single SSH key
# 
# Get a single key.
# 
# GET /user/keys/:id
# Parameters:
# 
# id (required) - The ID of an SSH key
# {
#   "id": 1,
#   "title": "Public key",
#   "key": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAIEAiPWx6WM4lhHNedGfBpPJNPpZ7yKu+dnn1SJejgt4596k6YjzGGphH2TUxwKzxcKDKKezwkpfnxPkSMkuEspGRt/aZZ9wa++Oi7Qkr8prgHc4soW6NUlfDzpvZK2H5E7eQaSeP3SAwGmQKUFHCddNaP0L+hM7zhFNzjFvpaMgJw0=",
#   "created_at": "2014-08-01T14:47:39.080Z"
# }
# Add SSH key
# 
# Creates a new key owned by the currently authenticated user.
# 
# POST /user/keys
# Parameters:
# 
# title (required) - new SSH Key's title
# key (required) - new SSH key
# {
#   "created_at": "2015-01-21T17:44:33.512Z",
#   "key": "ssh-dss AAAAB3NzaC1kc3MAAACBAMLrhYgI3atfrSD6KDas1b/3n6R/HP+bLaHHX6oh+L1vg31mdUqK0Ac/NjZoQunavoyzqdPYhFz9zzOezCrZKjuJDS3NRK9rspvjgM0xYR4d47oNZbdZbwkI4cTv/gcMlquRy0OvpfIvJtjtaJWMwTLtM5VhRusRuUlpH99UUVeXAAAAFQCVyX+92hBEjInEKL0v13c/egDCTQAAAIEAvFdWGq0ccOPbw4f/F8LpZqvWDydAcpXHV3thwb7WkFfppvm4SZte0zds1FJ+Hr8Xzzc5zMHe6J4Nlay/rP4ewmIW7iFKNBEYb/yWa+ceLrs+TfR672TaAgO6o7iSRofEq5YLdwgrwkMmIawa21FrZ2D9SPao/IwvENzk/xcHu7YAAACAQFXQH6HQnxOrw4dqf0NqeKy1tfIPxYYUZhPJfo9O0AmBW2S36pD2l14kS89fvz6Y1g8gN/FwFnRncMzlLY/hX70FSc/3hKBSbH6C6j8hwlgFKfizav21eS358JJz93leOakJZnGb8XlWvz1UJbwCsnR2VEY8Dz90uIk1l/UqHkA= loic@call",
#   "title": "ABC",
#   "id": 4
# }
# Will return created key with status 201 Created on success. If an error occurs a 400 Bad Request is returned with a message explaining the error:
# 
# {
#   "message": {
#     "fingerprint": [
#       "has already been taken"
#     ],
#     "key": [
#       "has already been taken"
#     ]
#   }
# }
# Add SSH key for user
# 
# Create new key owned by specified user. Available only for admin
# 
# POST /users/:id/keys
# Parameters:
# 
# id (required) - id of specified user
# title (required) - new SSH Key's title
# key (required) - new SSH key
# Will return created key with status 201 Created on success, or 404 Not found on fail.
# 
# Delete SSH key for current user
# 
# Deletes key owned by currently authenticated user. This is an idempotent function and calling it on a key that is already deleted or not available results in 200 OK.
# 
# DELETE /user/keys/:id
# Parameters:
# 
# id (required) - SSH key ID
# Delete SSH key for given user
# 
# Deletes key owned by a specified user. Available only for admin.
# 
# DELETE /users/:uid/keys/:id
# Parameters:
# 
# uid (required) - id of specified user
# id (required) - SSH key ID
# Will return 200 OK on success, or 404 Not found if either user or key cannot be found.
# 
# List emails
# 
# Get a list of currently authenticated user's emails.
# 
# GET /user/emails
# [
#   {
#     "id": 1,
#     "email": "email@example.com"
#   },
#   {
#     "id": 3,
#     "email": "email2@example.com"
#   }
# ]
# Parameters:
# 
# none
# List emails for user
# 
# Get a list of a specified user's emails. Available only for admin
# 
# GET /users/:uid/emails
# Parameters:
# 
# uid (required) - id of specified user
# Single email
# 
# Get a single email.
# 
# GET /user/emails/:id
# Parameters:
# 
# id (required) - email ID
# {
#   "id": 1,
#   "email": "email@example.com"
# }
# Add email
# 
# Creates a new email owned by the currently authenticated user.
# 
# POST /user/emails
# Parameters:
# 
# email (required) - email address
# {
#   "id": 4,
#   "email": "email@example.com"
# }
# Will return created email with status 201 Created on success. If an error occurs a 400 Bad Request is returned with a message explaining the error:
# 
# {
#   "message": {
#     "email": [
#       "has already been taken"
#     ]
#   }
# }
# Add email for user
# 
# Create new email owned by specified user. Available only for admin
# 
# POST /users/:id/emails
# Parameters:
# 
# id (required) - id of specified user
# email (required) - email address
# Will return created email with status 201 Created on success, or 404 Not found on fail.
# 
# Delete email for current user
# 
# Deletes email owned by currently authenticated user. This is an idempotent function and calling it on a email that is already deleted or not available results in 200 OK.
# 
# DELETE /user/emails/:id
# Parameters:
# 
# id (required) - email ID
# Delete email for given user
# 
# Deletes email owned by a specified user. Available only for admin.
# 
# DELETE /users/:uid/emails/:id
# Parameters:
# 
# uid (required) - id of specified user
# id (required) - email ID
# Will return 200 OK on success, or 404 Not found if either user or email cannot be found.
# 
# Block user
# 
# Blocks the specified user. Available only for admin.
# 
# PUT /users/:uid/block
# Parameters:
# 
# uid (required) - id of specified user
# Will return 200 OK on success, 404 User Not Found is user cannot be found or 403 Forbidden when trying to block an already blocked user by LDAP synchronization.
# 
# Unblock user
# 
# Unblocks the specified user. Available only for admin.
# 
# PUT /users/:uid/unblock
# Parameters:
# 
# uid (required) - id of specified user
# Will return 200 OK on success, 404 User Not Found is user cannot be found or 403 Forbidden when trying to unblock a user blocked by LDAP synchronization.
# 
# Generated from https://gitlab.com/gitlab-org/gitlab-ce at Wed Feb 10 16:20:28 2016, please submit improvements.
