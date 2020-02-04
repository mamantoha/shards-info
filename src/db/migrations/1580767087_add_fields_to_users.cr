class AddFieldsToUsers
  include Clear::Migration

  def change(direction)
    direction.up do
      add_column "users", "bio", "text", nullable: true
      add_column "users", "location", "text", nullable: true
      add_column "users", "company", "text", nullable: true
      add_column "users", "email", "text", nullable: true
      add_column "users", "website", "text", nullable: true
    end

    direction.down do
      add_column "users", "bio", "text"
      add_column "users", "location", "text"
      add_column "users", "company", "text"
      add_column "users", "email", "text"
      add_column "users", "website", "text"
    end
  end
end
