define_model 'Color' do |model_definition|
  model_definition.table 'color'
  model_definition.has_many(
      attribute_name: 'bricks',
      model_class: 'Brick',
      column_name: 'color_id'
  )
end

define_model 'Brick' do |model_definition|
  model_definition.table 'brick'
  model_definition.has_one(
      attribute_name: 'color',
      model_class: 'Color',
      column_name: 'color_id'
  )
  model_definition.has_many(
      attribute_name: 'kit_bricks',
      model_class: 'KitBricks',
      column_name: 'brick_id'
  )
end

define_model 'Kit' do |model_definition|
  model_definition.table 'kit'
  model_definition.has_many(
      attribute_name: 'kit_bricks',
      model_class: 'KitBricks',
      column_name: 'kit_id'
  )
end

define_model 'KitBrick' do |model_definition|
  model_definition.table 'kit_brick'
  model_definition.has_one(
      attribute_name: 'kit',
      model_class: 'Kit',
      column_name: 'kit_id'
  )
  model_definition.has_one(
      attribute_name: 'brick',
      model_class: 'Brick',
      column_name: 'brick_id'
  )
end