#@tool
extends Area2D

const SLIME := preload("res://scenes/entities/Slime.tscn")
const CELL := 32.0

@export var spike_width := 256.0:
	set(value):
		spike_width = value
		_update_spikes()

var taken: Array[int] = []


func _ready() -> void:
	_update_spikes()
	if not Engine.is_editor_hint():
		body_entered.connect(_on_body_entered)


func _update_spikes() -> void:
	var texture_rect := get_node_or_null("Texture") as TextureRect
	var collision := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if texture_rect == null or collision == null:
		return

	var width := maxf(spike_width, 32.0)
	texture_rect.offset_top = -16.0
	texture_rect.offset_right = width
	texture_rect.offset_bottom = 16.0

	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, 16.0)
	collision.shape = shape
	collision.position = Vector2(width * 0.5, 8.0)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("cat"):
		return

	body.die()
	await get_tree().create_timer(0.22).timeout

	var x: float = body.get_node("CollisionShape2D").global_position.x
	var cell := clampi(floori((x - global_position.x) / CELL), 0, int(spike_width / CELL) - 1)
	if cell in taken:
		return

	var from := Vector2(global_position.x + (cell + 0.5) * CELL, global_position.y + 8.0)
	var to := from + Vector2(0.0, 200.0)
	var query := PhysicsRayQueryParameters2D.create(from, to, 1, [body.get_rid()])
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return

	taken.append(cell)
	var slime := SLIME.instantiate()
	get_parent().add_child(slime)
	slime.global_position = Vector2(from.x, hit.position.y)
