class ModelDefinition

  MODELS_DEFINITIONS = []

  attr_reader :name, :table_name, :has_ones, :has_manys

  # @param name [String]
  def initialize(name)
    @name = name
    @has_ones = []
    @has_manys = []
    MODELS_DEFINITIONS << self
  end

  # @param [String]
  # @return [void]
  def table(table_name)
    @table_name = table_name
  end

  # @param attribute_name [String]
  # @param model_class [String]
  # @param column_name [String]
  # @return [void]
  def has_one(attribute_name:, model_class:, column_name:)
    @has_ones << {
        attribute_name: attribute_name,
        model_class: model_class,
        column_name: column_name
    }
  end

  def has_many(attribute_name:, model_class:, column_name:)
    @has_manys << {
        attribute_name: attribute_name,
        model_class: model_class,
        column_name: column_name
    }
  end
end

# @param model_name [String]
# @yield [model_definition]
# @yieldparam model_definition [ModelDefinition]
# @yieldreturn [void]
def define_model(model_name, &block)
  puts "Defining model [#{model_name}]"
  model_definition = ModelDefinition.new(model_name)
  block.yield(model_definition)
end

require_relative 'schema'

require 'erb'

require 'sqlite3'

DATABASE = SQLite3::Database.new('orm-ruby.sqlite')

class ColumnDefinition

  attr_reader :name, :type

  # @param name [String]
  # @param type [String]
  def initialize(name, type)
    @name = name
    @type = type
  end

end

# Load the template
erb = ERB.new(IO.read('models.rb.erb'))

SQLITE_TYPE_TO_RUBY_CLASS = {
    'INTEGER' => 'Integer',
    'TEXT' => 'String'
}

# Apply the template to the model definitions
models_code = ModelDefinition::MODELS_DEFINITIONS.map do |model|
  columns_definitions = DATABASE.table_info(model.table_name).collect do |column_info|
    column_name = column_info['name']
    sql_type = column_info['type']
    ruby_type = SQLITE_TYPE_TO_RUBY_CLASS[sql_type]
    ColumnDefinition.new(column_name, ruby_type)
  end
  erb.result_with_hash(model: model, columns_definitions: columns_definitions)
end

# Write the concatenated result to a file
IO.write(
    'models.rb',
    models_code.
        join("\n\n").
        # Clear lines with only spaces
        gsub(/\n\s*\n/, "\n\n").
        # When more than 2 lines break only use 2
        gsub(/\n{2,}/, "\n\n")
)