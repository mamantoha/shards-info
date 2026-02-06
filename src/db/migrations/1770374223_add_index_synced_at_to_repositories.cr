class AddIndexSyncedAtToRepositories
  include Lustra::Migration

  def change(dir)
    add_index "repositories", "synced_at"
  end
end
