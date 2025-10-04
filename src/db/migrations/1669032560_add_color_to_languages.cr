class AddColorToLanguages
  include Lustra::Migration

  def change(dir)
    dir.up do
      add_column "languages", "color", :string, nullable: true
    end

    dir.down do
      add_column "languages", "color", :string
    end
  end
end
