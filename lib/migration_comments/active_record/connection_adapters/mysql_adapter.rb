module MigrationComments::ActiveRecord::ConnectionAdapters
  module MysqlAdapter
    def self.included(base)
      base.class_eval do
        alias_method_chain :create_table, :migration_comments
        alias_method_chain :change_column, :migration_comments
      end
    end

    def create_table_with_migration_comments(table_name, options={})
      local_table_definition = nil
      create_table_without_migration_comments(table_name, options) do |td|
        local_table_definition = td
        local_table_definition.base = self
        local_table_definition.comment options[:comment] if options.has_key?(:comment)
        yield td if block_given?
      end
      comments = local_table_definition.collect_comments(table_name)
      comments.each do |comment_definition|
        execute_comment comment_definition
      end
    end

    def change_column_with_migration_comments(table_name, column_name, type, options={})
      unless options.keys.include?(:comment)
        options.merge!(:comment => retrieve_column_comment(table_name, column_name))
      end
      change_column_without_migration_comments(table_name, column_name, type, options)
    end
  end
end
