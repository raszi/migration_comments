module MigrationComments::ActiveRecord::ConnectionAdapters
  module AbstractSQLiteAdapter
    def change_column_with_migration_comments(table_name, column_name, type, options = {}) #:nodoc:
      adapter = self
      alter_table(table_name) do |definition|
        include_default = options_include_default?(options)
        definition[column_name].instance_eval do
          self.type    = type
          self.limit   = options[:limit] if options.include?(:limit)
          self.default = options[:default] if include_default
          self.null    = options[:null] if options.include?(:null)
          self.precision = options[:precision] if options.include?(:precision)
          self.scale   = options[:scale] if options.include?(:scale)
          self.comment = CommentDefinition.new(adapter, table_name, column_name, options[:comment]) if options.include?(:comment)
        end
      end
    end
  end
end
