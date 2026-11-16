#@tool
extends StaticBody2D

@export var platform_size := Vector2(256.0, 96.0):
	set(value):
		platform_size = value
		_update_platform()


func _ready() -> void:
	_update_platform()


func _update_platform() -> void:
	var grass := get_node_or_null("Grass") as TextureRect
	var dirt := get_node_or_null("Dirt") as TextureRect
	var collision := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if grass == null or dirt == null or collision == null:
		return

	var width := maxf(platform_size.x, 32.0)
	var height := maxf(platform_size.y, 32.0)

	grass.offset_right = width
	grass.offset_bottom = 32.0
 	
	dirt.offset_right = width
	dirt.offset_top = 32.0
	dirt.offset_bottom = height

	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, height)
	collision.shape = shape
	collision.position = Vector2(width * 0.5, height * 0.5)
