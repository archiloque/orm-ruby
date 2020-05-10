CREATE TABLE 'color' (
  'id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,

  'name' TEXT NOT NULL
);

CREATE UNIQUE INDEX idx_color_unique ON color('name');

CREATE TABLE 'brick' (
  'id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,

  'name' TEXT NOT NULL,
  'description' TEXT NOT NULL,
  'color_id' INTEGER NOT NULL,

  FOREIGN KEY('color_id') REFERENCES 'color'('id')
);

CREATE TABLE 'kit' (
  'id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  'name' TEXT NOT NULL,
  'description' TEXT NOT NULL
);

CREATE TABLE 'kit_bricks' (
  'id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,

  'kit_id' INTEGER NOT NULL,
  'brick_id' INTEGER NOT NULL,
  'quantity' INTEGER NOT NULL,

  FOREIGN KEY('kit_id') REFERENCES 'kit'('id'),
  FOREIGN KEY('brick_id') REFERENCES 'brick'('id')
);
CREATE UNIQUE INDEX 'idx_kit_brick_uniqu' ON 'kit_bricks'('kit_id', 'brick_id');