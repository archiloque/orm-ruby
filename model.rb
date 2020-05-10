require 'sqlite3'

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
    columns_names_except_id = self.class.columns.
        select { |column| column != 'id' }

    quoted_columns_names_except_id = columns_names_except_id.
        map { |column_name| SQLite3::Database.quote(column_name) }

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
    self.id = DATABASE.last_insert_row_id
  end

  # @param [String] filter
  # @param [Array] params
  # @return [Model::QueryParameters]
  def self.where(filter, *params)
    QueryParameters.new(self).where(filter, *params)
  end

  # @param [String] order_by
  # @return [Model::QueryParameters]
  def self.order_by(order_by)
    QueryParameters.new(self).order_by(order_by)
  end

  # @param [Integer] limit
  # @return [Model::QueryParameters]
  def self.limit(limit)
    QueryParameters.new(self).limit(limit)
  end

  # @return [Array]
  def self.all
    QueryParameters.new(self).all
  end

  # @return [Object]
  def self.first
    QueryParameters.new(self).first
  end

  # @return [void]
  def self.truncate
    DATABASE.execute("DELETE FROM #{quoted_table_name}")
  end

  class QueryParameters

    attr_writer :limit
    attr_reader :wheres, :order_bys, :limit

    # @param [Class] model_class
    def initialize(model_class)
      @model_class = model_class
      @wheres = []
      @order_bys = []
      @limit = nil
    end

    # @param [String] filter
    # @param [Array] params
    # @return [Model::QueryParameters]
    def where(filter, *params)
      new_query_parameters = self.dup
      new_query_parameters.wheres << [filter, params]
      new_query_parameters
    end

    # @param [String] order_by
    # @return [Model::QueryParameters]
    def order_by(order_by)
      new_query_parameters = self.dup
      new_query_parameters.order_bys << order_by
      new_query_parameters
    end

    # @param [Integer] limit
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
        where_clause = "WHERE #{@wheres.map { |filter| filter[0] }.join(' AND ')} "
        where_params = @wheres.map { |filter| filter[1] }.flatten
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
      #   FROM 'table_name'
      #   WHERE column_1 = ? AND column_2 = ?
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