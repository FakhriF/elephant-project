## Draws a selected unit's walkable tiles.
class_name UnitOverlay
extends TileMap


## Fills the tilemap with the cells, giving a visual representation of the cells a unit can walk.
func draw(cells: Array, Type: String) -> void:
	clear()
	for cell in cells:
		if Type == "Ally":
			set_cell(0, cell, 3, Vector2i(0,0))
		elif Type == "Enemy":
			set_cell(0, cell, 2, Vector2i(0,0))
		else:
			set_cell(0, cell, 1, Vector2i(0,0))
