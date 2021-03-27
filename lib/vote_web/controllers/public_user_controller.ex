defmodule VoteWeb.PublicUserController do
  use VoteWeb, :controller

  defmodule UserSchema do
    use Ecto.Schema
    import Ecto.Changeset

    schema "user" do
      field :name, :string, virtual: true
    end

    def changeset(model, params) do
      model
      |> cast(params, [:name])
      |> validate_required([:name])
      |> validate_length(:name, min: 3)
      |> Map.put(:action, :insert)
    end

    def change(params \\ %{}) do
      changeset(%UserSchema{}, params)
    end
  end

  def index(conn, %{"ballot" => slug}) do
    case get_session(conn, :public_user) do
      nil -> render(conn, :index, cs: UserSchema.change(), slug: slug)
      _el -> redirect(conn, to: Routes.ballot_path(conn, :index, slug))
    end
  end

  def assign(conn, %{"pick_user" => params, "ballot" => slug}) do
    case UserSchema.change(params) do
      %Ecto.Changeset{errors: [_ | _]} = cs ->
        render(conn, :index, cs: cs, slug: slug)
      cs ->
        conn
        |> put_session(:public_user, Ecto.Changeset.get_field(cs, :name))
        |> redirect(to: Routes.ballot_path(conn, :index, slug))
    end
  end
end
