.PHONY: db-dump db-dump-schema db-dump-migrations db-restore

DB_NAME ?= shards_info_development
SCHEMA_FILE = src/db/structure.sql

# Dump schema only
db-dump-schema:
	pg_dump \
	  --schema-only \
	  --no-owner \
	  --no-privileges \
	  $(DB_NAME) \
	  > $(SCHEMA_FILE)

# Dump migrations metadata only
db-dump-migrations:
	pg_dump \
	  --data-only \
	  --inserts \
	  --no-owner \
	  --table=__lustra_metadatas \
	  $(DB_NAME) \
	  >> $(SCHEMA_FILE)

# Dump both schema and migrations
db-dump: db-dump-schema db-dump-migrations

# Restore from dump
db-restore:
	psql -d $(DB_NAME) -f $(SCHEMA_FILE)

# Help
help:
	@echo "Available targets:"
	@echo "  make db-dump-schema       - Dump schema only"
	@echo "  make db-dump-migrations   - Append migrations metadata"
	@echo "  make db-dump              - Dump schema and migrations (combined)"
	@echo "  make db-restore           - Restore from dump"
	@echo ""
	@echo "Environment variable:"
	@echo "  DB_NAME (default: $(DB_NAME))"
