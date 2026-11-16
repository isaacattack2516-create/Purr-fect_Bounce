extends StaticBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var full := sprite.scale


func _ready() -> void:
	$Top.body_entered.connect(_on_top_entered)
	sprite.scale = Vector2.ZERO
	var pop := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	pop.tween_property(sprite, "scale", full, 0.25)


func _on_top_entered(body: Node2D) -> void:
	if not body.is_in_group("cat") or body.dead or body.velocity.y < 0.0:
		return

	body.bounce()

	var tween := create_tween()
	tween.tween_property(sprite, "scale", full * Vector2(1.3, 0.6), 0.06)
	tween.tween_property(sprite, "scale", full * Vector2(0.85, 1.25), 0.09)
	tween.tween_property(sprite, "scale", full, 0.1)
