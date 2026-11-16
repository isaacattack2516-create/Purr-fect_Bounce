extends Node2D

@export var lives := 9
var time := 0.0
var running := true

@onready var cat := $Cat
@onready var hud := $Hud
@onready var goal := $Goal


func _ready() -> void:
	cat.died.connect(_on_died)
	goal.reached.connect(_on_reached)
	hud.retry.connect(get_tree().reload_current_scene)
	hud.next.connect(_on_next)
	hud.set_lives(lives)


func _process(delta: float) -> void:
	if running:
		time += delta
		hud.set_time(time)


func _on_died() -> void:
	lives -= 1
	hud.set_lives(lives)

	if lives == 0:
		running = false
		cat.locked = true
		await get_tree().create_timer(0.8).timeout
		hud.show_lost()


func _on_reached() -> void:
	running = false
	await cat.vanish(goal.global_position + Vector2(0.0, -24.0))
	hud.show_win(time, lives, goal.next_level == null)


func _on_next() -> void:
	if goal.next_level:
		get_tree().change_scene_to_packed(goal.next_level)
	else:
		get_tree().change_scene_to_file("res://scenes/levels/Level1.tscn")
