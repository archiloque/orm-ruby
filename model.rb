require 'sqlite3'

# @abstract
class Model

  DATABASE = SQLite3::Database.new('orm-ruby.sqlite')

  # @abstract
  # @return [String]
  def self.table_name
    raise NotImplementedError
  end

  # @abstract
  # @return [Array<String>]
  def self.columns
    raise NotImplementedError
  end

  # @return [String]
  def self.quoted_table_name
    "'#{SQLite3::Database.quote(table_name)}'"
  end

  # @return [void]
  def insert
    # Columns names without 'id'
    # because the id values are managed by the database
    columns_names_except_id = self.class.columns.
        select { |column| column != 'id' }

    # Quote the columns names to avoid escaping issues
    quoted_columns_names_except_id = columns_names_except_id.
        map { |column_name| SQLite3::Database.quote(column_name) }

    # Columns vales without 'id'
    columns_values_except_id = columns_names_except_id.
        map { |column_name| self.send(column_name) }

    # Query looks like
    # INSERT INTO table_name
    #   (column_name_1, column_name_2, …)
    #   VALUES (?, ?, …)
    DATABASE.execute(
        "INSERT INTO #{self.class.quoted_table_name} " +
            "(#{quoted_columns_names_except_id.join(', ')}) " +
            "VALUES (#{Array.new(columns_names_except_id.length, '?').join(', ')})",
        columns_values_except_id
    )

    # Set the `id` of the model from the value provided by the database
    self.id = DATABASE.last_insert_row_id
  end

  # @return [Model::QueryParameters]
  def self.query_parameters
    QueryParameters.new(self)
  end

  # @param [String] filter
  # @param [Array] params
  # @return [Model::QueryParameters]
  def self.where(filter, *params)
    query_parameters.where(filter, *params)
  end

  # @param [String] order_by
  # @return [Model::QueryParameters]
  def self.order_by(order_by)
    query_parameters.order_by(order_by)
  end

  # @param limit [Integer]
  # @return [Model::QueryParameters]
  def self.limit(limit)
    query_parameters.limit(limit)
  end

  # @return [Array]
  def self.all
    query_parameters.all
  end

  # @return [Object]
  def self.first
    query_parameters.first
  end

  # @return [void]
  def self.truncate
    DATABASE.execute("DELETE FROM #{quoted_table_name}")
  end

  class QueryParameters

    attr_writer :limit
    attr_reader :wheres, :order_bys, :limit

    # @param model_class [Class]
    def initialize(model_class)
      @model_class = model_class
      @wheres = []
      @order_bys = []
      @limit = nil
    end

    # @param expression [String]
    # @param parameters [Array]
    # @return [Model::QueryParameters]
    def where(expression, *parameters)
      new_query_parameters = self.dup
      new_query_parameters.wheres << {expression: expression, parameters: parameters}
      new_query_parameters
    end

    # @param order_by [String]
    # @return [Model::QueryParameters]
    def order_by(order_by)
      new_query_parameters = self.dup
      new_query_parameters.order_bys << order_by
      new_query_parameters
    end

    # @param limit [Integer]
    # @return [Model::QueryParameters]
    def limit(limit)
      new_query_parameters = self.dup
      new_query_parameters.limit = limit
      new_query_parameters
    end

    # @return [Array]
    def all
      quoted_columns_names = @model_class.columns.
          map { |column_name| SQLite3::Database.quote(column_name) }

      if @wheres.empty?
        where_clause = ' '
        where_params = []
      else
        where_clause = "WHERE #{@wheres.map { |where| where[:expression] }.join(' AND ')} "
        where_params = @wheres.map { |where| where[:parameters] }.flatten
      end

      if @order_bys.empty?
        order_by_clause = ''
      else
        order_by_clause = "ORDER BY #{@order_bys.join(', ')} "
      end

      if @limit.nil?
        limit_clause = ' '
      else
        limit_clause = "LIMIT #{@limit} "
      end

      # Query looks like
      # SELECT column_name_1, column_name_2, …
      #   FROM table_name
      #   WHERE column_A = ? AND column_B < ?
      #   ORDER BY column_X asc, column_Y desc
      #   LIMIT 10
      DATABASE.execute(
          "SELECT #{quoted_columns_names.join(', ')} " +
              "FROM #{@model_class.quoted_table_name} " +
              where_clause +
              order_by_clause +
              limit_clause,
          where_params
      ).map do |result_row|
        model_instance = @model_class.new
        @model_class.columns.each_with_index do |column, column_index|
          model_instance.send("#{column}=", result_row[column_index])
        end
        model_instance
      end
    end

    def first
      limit(1).all.first
    end
  end
end