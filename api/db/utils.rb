# frozen_string_literal: true

module DB
  class TableColumns
    attr_reader :columns, :nullable_columns

    def self.get_columns_set(model_class)
      t = TableColumns.new
      model_class.define_table_schema(t)
      t.columns
    end

    def self.get_nullable_set(model_class)
      t = TableColumns.new
      model_class.define_table_schema(t)
      t.nullable_columns
    end

    def initialize
      @columns = Set.new
      @nullable_columns = Set.new
    end

    # Override ActiveRecord::ConnectionAdapters::TableDefinition methods
    # ref. https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/TableDefinition.html
    def timestamps(*_args)
      @columns << :created_at
      @columns << :updated_at
    end

    def belongs_to(*_args); end
    def check_constraint(*_args); end
    def foreign_key(*_args); end

    def index(*_args); end
    def references(*_args); end
    def set_primary_key(*_args); end

    def column(name, *_args, null: true, **_kwargs)
      sym = name.to_sym
      @columns << sym
      @nullable_columns << sym if null
    end

    # ActiveRecord::Schema.define の t.string 等をキャッチする
    def method_missing(_method, name, *args, **kwargs) # rubocop:disable Style/MissingRespondToMissing
      column(name, *args, **kwargs)
    end
  end
end
