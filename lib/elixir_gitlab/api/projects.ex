defmodule ElixirGitlab.API.Projects do

  alias  ElixirGitlab.API
  import ElixirGitlab.Util.Options



  defmodule GitLabProject do
    defstruct [
      archived:               false,
      avatar_url:             nil,
      builds_enabled:         false,
      created_at:             nil,
      creator_id:             3,
      default_branch:         "master",
      description:            nil,
      forks_count:            0,
      http_url_to_repo:       "",
      id:                     4,
      issues_enabled:         true,
      last_activity_at:       nil,
      merge_requests_enabled: true,
      name:                   "",
      name_with_namespace:    "",
      namespace:              nil,    # %GitlabProjectNamespace
      open_issues_count:      0,
      owner:                  nil,    # %GitlabProjectOwner
      path:                   "",
      path_with_namespace:    "",
      public:                 false,
      public_builds:          true,
      runners_token:          nil,
      shared_runners_enabled: true,
      snippets_enabled:       false,
      ssh_url_to_repo:        "",
      star_count:             0,
      tag_list:               [],
      visibility_level:       0,
      web_url:                "",
      wiki_enabled:           false,
    ]

    defmodule GitlabProject.Namespace do
      defstruct [
        created_at:  nil,
        description: "",
        id:          -1,
        name:        "",
        owner_id:    -1,
        path:        "",
        updated_at:  nil,
      ]
    end

    defmodule GitlabProject.Owner do
      defstruct [
        created_at: nil,
        id:         -1,
        name:       "",
      ]
    end
    
  end


  @doc """
  List projects optionally meeting some criteria. The results may be
  ordered on certain fields, and the sort may be ascnding or descending.

  Options are:

  * `archived`    — limit by archived status
  * `visibility`  — limit by visibility (`:public`, `:internal`, `:private`)
  * `order_by`    — order results id, name, path, created_at, \
                    updated_at or last_activity_at fields. Default is created_at
  * `sort`        — sort in `:asc` or `:desc` order. Default is desc
  * `search`      — return list of authorized projects according to a \
                    search criteria
  """

  @list_opts %{
    optional: MapSet.new([:archived, :visibility, :order_by, :sort, :search])
  }

  def list(options \\ []) do
    call_with_options(:get, "projects", options, @list_opts)
  end


  @doc """
  Like `list`, but all projects (admin only)

  Takes the same options as `list`.
  """
  def list_all(options \\ []) do
    call_with_options(:get, "projects/all", options, @list_opts)
  end

  
  @doc """
  Like `list`, but restricted to the currently authenticated user.

  Takes the same options as `list`.
  """
  def list_owned(options \\ []) do
    call_with_options(:get, "projects/owned", options, @list_opts)
  end

  @doc """
  Like `list`, but restricted to starred pojects.

  Takes the same options as `list`.
  """
  def list_starred(options \\ []) do
    call_with_options(:get, "projects/starred", options, @list_opts)
  end


  @doc """
  Return a project by id (which cn be the actual id or the
  namespace/project string.
  """

  def find_by_id(id) do
    API.get("projects/#{id}")
  end


  @doc """
  Return the events for a project, identified by id or the
  namespace/project string.
  """

  def events_by_id(id) do
    API.get("projects/#{id}/events")
  end

  @doc """
  Creates a new project owned by the authenticated user.

  Options (only `name` is required):

  * name          — new project name
  * path          — custom repository name for new project. By default generated based on name
  * namespace_id  — namespace for the new project (defaults to user)
  * description   — short project description
  * public        — if true same as setting visibility_level = 20
  * visibility_level
  * import_url
  * public_builds
  * issues_enabled
  * merge_requests_enabled
  * builds_enabled
  * wiki_enabled
  * snippets_enabled

  """

  @create_opts %{
    required:  MapSet.new([:name]),
    optional:  MapSet.new([
      :builds_enabled, :description, :import_url, :issues_enabled,
      :merge_requests_enabled, :namespace_id, :path, :public,
      :public_builds, :snippets_enabled, :visibility_level, :wiki_enabled,
    ])
  }

  def create(options) when is_list(options) do
    call_with_options(:post, "projects", options, @create_opts)
  end

  @doc """
  Creates a new project owned by the specified user. Available only for admins.
  The project is namespaced to that user.

  Options:

  * name (required) - new project name
  * builds_enabled (optional)
  * description (optional) - short project description
  * import_url (optional)
  * issues_enabled (optional)
  * merge_requests_enabled (optional)
  * public (optional) - if true same as setting visibility_level = 20
  * public_builds (optional)
  * snippets_enabled (optional)
  * visibility_level (optional)
  * wiki_enabled (optional)

  """

  @create_for_user_opts %{
    required:  MapSet.new([:name]),
    optional:  MapSet.new([
      :builds_enabled, :description, :import_url, :issues_enabled,
      :merge_requests_enabled, :public,
      :public_builds, :snippets_enabled, :visibility_level, :wiki_enabled,
    ])
  }

  def create_for_user(user_id, options)
  when is_integer(user_id) and is_list(options) do
    call_with_options(:post, "projects/user/#{user_id}", options, @create_for_user_opts)
  end

  @doc """
  Creates a new project owned by the specified user. Available only for admins.
  The project is namespaced to that user. Options are the same as `create_for_user`,
  although `name` is optional.
  """

  @edit_project_opts %{
    optional:  MapSet.new([
      :builds_enabled, :description, :import_url, :issues_enabled,
      :merge_requests_enabled, :name, :public,
      :public_builds, :snippets_enabled, :visibility_level, :wiki_enabled,
    ])
  }

  def edit_project(project_id, options)
  when is_integer(project_id) and is_list(options) do
    call_with_options(:put, "projects/#{project_id}", options, @edit_project_opts)
  end



end
