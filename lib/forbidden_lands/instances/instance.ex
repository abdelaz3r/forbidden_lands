defmodule ForbiddenLands.Instances.Instance do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias ForbiddenLands.Calendar
  alias ForbiddenLands.Instances.Event
  alias ForbiddenLands.Instances.Instance
  alias ForbiddenLands.Instances.Media
  alias ForbiddenLands.Instances.ResourceRule
  alias ForbiddenLands.Instances.Stronghold

  @exported_fields [
    :name,
    :prepend_name,
    :append_name,
    :initial_date,
    :current_date,
    :description,
    :introduction,
    :stronghold,
    :resource_rules,
    :medias,
    :events
  ]

  @derive {ForbiddenLands.Export, fields: @exported_fields}
  @type t() :: %Instance{
          id: non_neg_integer() | nil,
          name: String.t() | nil,
          username: String.t() | nil,
          password: String.t() | nil,
          hashed_password: String.t() | nil,
          prepend_name: String.t() | nil,
          append_name: String.t() | nil,
          human_date: String.t() | nil,
          initial_date: integer() | nil,
          current_date: integer() | nil,
          mood: String.t() | nil,
          overlay: String.t() | nil,
          description: String.t() | nil,
          introduction: String.t() | nil,
          stronghold: Stronghold.t() | nil,
          resource_rules: [ResourceRule.t()] | %Ecto.Association.NotLoaded{} | nil,
          medias: [Media.t()] | %Ecto.Association.NotLoaded{} | nil,
          events: [Event.t()] | nil
        }
  schema("instances") do
    field(:name, :string)
    field(:username, :string)
    field(:password, :string, virtual: true)
    field(:hashed_password, :string, redact: true)
    field(:prepend_name, :string)
    field(:append_name, :string)
    field(:human_date, :string, virtual: true)
    field(:initial_date, :integer)
    field(:current_date, :integer)
    field(:mood, :string)
    field(:overlay, :string)
    field(:description, :string)
    field(:introduction, :string)
    embeds_one(:stronghold, Stronghold, on_replace: :update)
    embeds_many(:resource_rules, ResourceRule, on_replace: :delete)
    embeds_many(:medias, Media, on_replace: :delete)
    has_many(:events, Event)

    timestamps(type: :naive_datetime_usec)
  end

  @spec create() :: Ecto.Changeset.t()
  @spec create(map()) :: Ecto.Changeset.t()
  def create(params \\ %{}) do
    %Instance{}
    |> cast(params, [:name, :username, :password, :human_date])
    |> validate_required([:name, :username, :password, :human_date])
    |> ForbiddenLands.Validation.validate_date(:human_date)
    |> put_dates()
    |> maybe_hash_password()
  end

  @spec create_from_export() :: Ecto.Changeset.t()
  @spec create_from_export(map()) :: Ecto.Changeset.t()
  def create_from_export(params \\ %{}) do
    %Instance{}
    |> cast(params, [
      :name,
      :username,
      :password,
      :initial_date,
      :current_date,
      :prepend_name,
      :append_name,
      :description,
      :introduction
    ])
    |> validate_required([:name, :username, :password, :initial_date, :current_date])
    |> cast_embed(:stronghold, with: &Stronghold.changeset/2)
    |> cast_embed(:resource_rules, with: &ResourceRule.create/2)
    |> cast_embed(:medias, with: &Media.create/2)
    |> cast_assoc(:events, with: &Event.create_from_export/2)
    |> maybe_hash_password()
  end

  @spec update(Instance.t()) :: Ecto.Changeset.t()
  @spec update(Instance.t(), map()) :: Ecto.Changeset.t()
  @spec update(Instance.t(), map(), list()) :: Ecto.Changeset.t()
  @spec update(Instance.t(), map(), list(), list()) :: Ecto.Changeset.t()
  def update(instance, params \\ %{}, resource_rules \\ [], medias \\ []) do
    instance
    |> cast(params, [
      :name,
      :username,
      :password,
      :current_date,
      :mood,
      :overlay,
      :prepend_name,
      :append_name,
      :description,
      :introduction
    ])
    |> validate_required([:name, :current_date, :mood])
    |> cast_embed(:stronghold, with: &Stronghold.changeset/2)
    |> put_embed(:resource_rules, resource_rules)
    |> put_embed(:medias, medias)
    |> maybe_hash_password()
  end

  @spec verify_credential(Instance.t(), String.t(), String.t()) :: boolean()
  def verify_credential(%{username: username, hashed_password: password}, _username, _password)
      when is_nil(username) or is_nil(password),
      do: true

  def verify_credential(instance, username, password) do
    Plug.Crypto.secure_compare(instance.username, username) and
      Bcrypt.verify_pass(password, instance.hashed_password)
  end

  defp put_dates(instance) do
    if not is_nil(get_change(instance, :human_date)) and not Keyword.has_key?(instance.errors, :human_date) do
      {:ok, calendar} = Calendar.from_date(get_field(instance, :human_date))

      instance
      |> put_change(:initial_date, calendar.count.quarters)
      |> put_change(:current_date, calendar.count.quarters)
    else
      instance
    end
  end

  defp maybe_hash_password(changeset) do
    password = get_change(changeset, :password)

    if password do
      changeset
      |> validate_length(:password, max: 72, count: :bytes)
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end
end
