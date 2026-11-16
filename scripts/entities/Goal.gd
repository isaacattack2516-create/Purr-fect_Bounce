extends Area2D

signal reached

@export var next_level: PackedScene


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("cat"):
		set_deferred("monitoring", false)
		reached.emit()
