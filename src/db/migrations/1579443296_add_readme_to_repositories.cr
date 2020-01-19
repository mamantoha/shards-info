class AddReadmeToRepositories
  include Clear::Migration

  def change(direction)
    direction.up do
      add_column "repositories", "readme", "text"
    end

    direction.down do
      drop_column "repositories", "readme", "text"
    end
  end
end
