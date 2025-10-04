class AddForkToRepositories
  include Lustra::Migration

  def change(dir)
    dir.up do
      add_column "repositories", "fork", :bool, nullable: false, default: "false"
    end

    dir.down do
      add_column "repositories", "fork", :bool
    end
  end
end
