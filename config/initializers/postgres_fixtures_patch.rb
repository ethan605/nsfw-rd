# https://github.com/rails/rails/issues/22584#issuecomment-168844779

# require 'active_record/connection_adapters/postgresql_adapter'

# module PostgresFixturesPatch
#   def insert_fixture(fixture, table_name)
#     # A regression with rails 4.2.5 breaks fixtures with symbol keys, specifically this one method.
#     # So, stringify keys in the fixture hash being sent to this method.
#     super(fixture.stringify_keys, table_name)
#   end
# end

# ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.include(PostgresFixturesPatch)