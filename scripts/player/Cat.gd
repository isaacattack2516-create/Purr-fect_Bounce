extends CharacterBody2D

signal died

const SPEED := 180.0
const JUMP_VELOCITY := -360.0
const BOUNCE_VELOCITY := -690.0

var dead := false
var locked := false
var spawn := Vector2.ZERO

@onready var sprite: Sprite2D = $Sprite2D
@onready var sprite_scale := sprite.scale


func _ready() -> void:
	spawn = global_position
	add_to_group("cat")


func _physics_process(delta: float) -> void:
	if dead:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * SPEED
	move_and_slide()


func die() -> void:
	if dead:
		return

	dead = true
	velocity = Vector2.ZERO
	set_physics_process(false)
	sprite.modulate = Color(1.0, 0.35, 0.35)
	died.emit()

	await get_tree().create_timer(0.85).timeout
	if locked:
		return

	global_position = spawn
	sprite.modulate = Color.WHITE
	dead = false
	set_physics_process(true)


func vanish(to: Vector2) -> void:
	locked = true
	set_physics_process(false)

	var tween := create_tween().set_parallel()
	tween.tween_property(self, "global_position", to, 0.5)
	tween.tween_property(sprite, "scale", Vector2.ZERO, 0.5)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
	await tween.finished


func bounce() -> void:
	velocity.y = BOUNCE_VELOCITY

	var tween := create_tween()
	tween.tween_property(sprite, "scale", sprite_scale * Vector2(0.8, 1.3), 0.08)
	tween.tween_property(sprite, "scale", sprite_scale, 0.15)
