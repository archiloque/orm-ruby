class Color < Model

  # @return [String]
  def self.table_name
      'color'
  end

  # @return [Array<String>]
  def self.columns
      ["id", "name"]
  end

  # @return [ Integer]
  def id
    @id
  end

  # @param [Integer] id
  # @return [void]
  def id=(id)
    @id = id
  end

  # @return [ String]
  def name
    @name
  end

  # @param [String] name
  # @return [void]
  def name=(name)
    @name = name
  end

  # @return [Array<Brick>]
  def bricks
    Brick.where('color_id = ?', id).all
  end

end

class Brick < Model

  # @return [String]
  def self.table_name
      'brick'
  end

  # @return [Array<String>]
  def self.columns
      ["id", "name", "description", "color_id"]
  end

  # @return [ Integer]
  def id
    @id
  end

  # @param [Integer] id
  # @return [void]
  def id=(id)
    @id = id
  end

  # @return [ String]
  def name
    @name
  end

  # @param [String] name
  # @return [void]
  def name=(name)
    @name = name
  end

  # @return [ String]
  def description
    @description
  end

  # @param [String] description
  # @return [void]
  def description=(description)
    @description = description
  end

  # @return [ Integer]
  def color_id
    @color_id
  end

  # @param [Integer] color_id
  # @return [void]
  def color_id=(color_id)
    @color_id = color_id
  end

  # @return [Color]
  def color
    Color.where('id = ?', color_id).first
  end

  # @param [Color] color
  # @return [void]
  def color=(color)
    @color_id = color.id
  end

  # @return [Array<KitBricks>]
  def kit_bricks
    KitBricks.where('brick_id = ?', id).all
  end

end

class Kit < Model

  # @return [String]
  def self.table_name
      'kit'
  end

  # @return [Array<String>]
  def self.columns
      ["id", "name", "description"]
  end

  # @return [ Integer]
  def id
    @id
  end

  # @param [Integer] id
  # @return [void]
  def id=(id)
    @id = id
  end

  # @return [ String]
  def name
    @name
  end

  # @param [String] name
  # @return [void]
  def name=(name)
    @name = name
  end

  # @return [ String]
  def description
    @description
  end

  # @param [String] description
  # @return [void]
  def description=(description)
    @description = description
  end

  # @return [Array<KitBricks>]
  def kit_bricks
    KitBricks.where('kit_id = ?', id).all
  end

end

class KitBrick < Model

  # @return [String]
  def self.table_name
      'kit_brick'
  end

  # @return [Array<String>]
  def self.columns
      ["id", "kit_id", "brick_id", "quantity"]
  end

  # @return [ Integer]
  def id
    @id
  end

  # @param [Integer] id
  # @return [void]
  def id=(id)
    @id = id
  end

  # @return [ Integer]
  def kit_id
    @kit_id
  end

  # @param [Integer] kit_id
  # @return [void]
  def kit_id=(kit_id)
    @kit_id = kit_id
  end

  # @return [ Integer]
  def brick_id
    @brick_id
  end

  # @param [Integer] brick_id
  # @return [void]
  def brick_id=(brick_id)
    @brick_id = brick_id
  end

  # @return [ Integer]
  def quantity
    @quantity
  end

  # @param [Integer] quantity
  # @return [void]
  def quantity=(quantity)
    @quantity = quantity
  end

  # @return [Kit]
  def kit
    Kit.where('id = ?', kit_id).first
  end

  # @param [Kit] kit
  # @return [void]
  def kit=(kit)
    @kit_id = kit.id
  end

  # @return [Brick]
  def brick
    Brick.where('id = ?', brick_id).first
  end

  # @param [Brick] brick
  # @return [void]
  def brick=(brick)
    @brick_id = brick.id
  end

end