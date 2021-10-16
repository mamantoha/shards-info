class AddDefaultBranchToRepositories
  include Clear::Migration

  def change(direction)
    direction.up do
      add_column "repositories", "default_branch", :string, default: "'master'"
    end

    direction.down do
      add_column "repositories", "default_branch", :string
    end
  end
end
