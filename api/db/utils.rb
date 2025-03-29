module DB
  class TableColumnsGenerator
    attr_reader :columns

    def self.get_columns_set(model_class)
      t = TableColumnsGenerator.new
      model_class.define_table_schema(t)
      t.columns
    end

    def initialize
      @columns = Set.new
    end

    def timestamps(*_args)
      @columns << :created_at
      @columns << :updated_at
    end

    # ActiveRecord::Schema.define の t.string 等をキャッチする
    def method_missing(_type, name, *_args)
      @columns << name.to_sym
    end
  end
end
