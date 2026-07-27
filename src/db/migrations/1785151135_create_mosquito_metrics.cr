class CreateMosquitoMetrics
  include Lustra::Migration

  def change(dir)
    create_table(:mosquito_metrics) do |t|
      t.column :day, :date, null: false, index: true
      t.column :queue_name, :string, null: false
      t.column :succeeded, :int64, null: false, default: 0_i64
      t.column :failed, :int64, null: false, default: 0_i64
      t.column :preempted, :int64, null: false, default: 0_i64
      t.column :aborted, :int64, null: false, default: 0_i64
      t.column :runtime_ms, :int64, null: false, default: 0_i64

      t.timestamps
      t.index [:queue_name, :day], using: :btree, unique: true
    end
  end
end
