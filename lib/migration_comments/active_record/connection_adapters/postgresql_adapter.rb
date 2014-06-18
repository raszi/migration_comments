module MigrationComments::ActiveRecord::ConnectionAdapters
  module PostgreSQLAdapter
    def self.included(base)
      base.class_eval do
        alias_method_chain :create_table, :migration_comments
        alias_method_chain :add_column, :migration_comments
        alias_method_chain :change_column, :migration_comments
      end
    end

    def create_table_with_migration_comments(table_name, options = {})
      local_table_definition = nil
      create_table_without_migration_comments(table_name, options) do |td|
        local_table_definition = td
        local_table_definition.base = self
        local_table_definition.comment options[:comment] if options.has_key?(:comment)
        yield td if block_given?
      end
      comments = local_table_definition.collect_comments(table_name)
      comments.each do |comment_definition|
        execute comment_definition.to_sql
      end
    end

    def add_column_with_migration_comments(table_name, column_name, type, options = {})
      add_column_without_migration_comments(table_name, column_name, type, options)
      if options[:comment]
        set_column_comment(table_name, column_name, options[:comment])
      end
    end

    def change_column_with_migration_comments(table_name, column_name, type, options = {})
      change_column_without_migration_comments(table_name, column_name, type, options)
      if options.keys.include?(:comment)
        set_column_comment(table_name, column_name, options[:comment])
      end
    end
  end
end
