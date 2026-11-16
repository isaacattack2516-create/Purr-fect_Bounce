extends Node2D

@export var thickness := 50.0
@export var length := 604.0

var firing := false
var warning := false


func _ready() -> void:
	var tex: Texture2D = get_node("Art").texture
	var k := thickness / tex.get_height()
	get_node("Art").scale = Vector2(k, k)
	get_node("Art").region_rect = Rect2(0, 0, length / k, tex.get_height())

	var shape := RectangleShape2D.new()
	shape.size = Vector2(length, thickness - 6.0)
	get_node("Hit/CollisionShape2D").shape = shape
	get_node("Hit").position = Vector2(length / 2.0, thickness / 2.0)
	get_node("Hit").monitoring = false
	get_node("Hit").body_entered.connect(_on_hit)

	get_node("Art").hide()
	get_node("Arrows").hide()


func _physics_process(delta: float) -> void:
	if firing == true:
		var bodies = get_node("Hit").get_overlapping_bodies()
		for i in range(bodies.size()):
			if bodies[i].is_in_group("cat") == true:
				bodies[i].die()


func _on_hit(body: Node2D) -> void:
	if body.is_in_group("cat") == true:
		body.die()


func warn(t: float) -> void:
	warning = true
	get_node("Arrows").show()
	await get_tree().create_timer(t).timeout
	if firing == false:
		get_node("Arrows").hide()
	warning = false


func fire(d: float) -> void:
	firing = true
	get_node("Art").show()
	get_node("Arrows").hide()
	get_node("Hit").monitoring = true
	await get_tree().create_timer(d).timeout
	firing = false
	get_node("Art").hide()
	get_node("Hit").monitoring = false
