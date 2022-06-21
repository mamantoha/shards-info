class AddDefaultBranchToRepositories
  include Clear::Migration

  def change(dir)
    dir.up do
      add_column "repositories", "default_branch", :string, default: "'master'"
    end

    dir.down do
      add_column "repositories", "default_branch", :string
    end
  end
end
