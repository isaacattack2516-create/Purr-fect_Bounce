extends Node2D

const POSES := {
	"idle": preload("res://art/larry/larry-idle.png"),
	"smirk": preload("res://art/larry/larry-smirk.png"),
	"angry": preload("res://art/larry/larry-angry.png"),
	"shocked": preload("res://art/larry/larry-shocked.png"),
	"happy": preload("res://art/larry/larry-happy.png"),
	"troll": preload("res://art/larry/larry-trollface.png"),
	"evil": preload("res://art/larry/larry-trollface-evil.png"),
}

@export var auto := true

var hp := 3
var open := false
var hit := false
var done := false
var taunted2 := false
var taunted3 := false
var round1 := 0
var round2 := 0
var t := 0.0

@onready var art: Sprite2D = $Art
@onready var glow: Sprite2D = $Glow
@onready var cat := get_node("../Cat")
@onready var goal := get_node("../Goal")


func _ready() -> void:
	get_node("Face").body_entered.connect(_on_face)
	get_node("../Cat").died.connect(_on_cat_died)
	get_node("../Music").stream.loop = true
	get_node("Glow").hide()
	pose("idle")
	show_hp()
	if auto == true:
		run()


func _process(delta: float) -> void:
	t = t + delta
	get_node("../Bar/Label").text = "larry hp: " + str(hp)
	get_node("../Bar/Fill").size.x = 180.0 * hp / 3.0


func pose(name: String) -> void:
	if name == "idle":
		get_node("Art").texture = POSES["idle"]
		get_node("Glow").texture = POSES["idle"]
	elif name == "smirk":
		get_node("Art").texture = POSES["smirk"]
		get_node("Glow").texture = POSES["smirk"]
	elif name == "angry":
		get_node("Art").texture = POSES["angry"]
		get_node("Glow").texture = POSES["angry"]
	elif name == "shocked":
		get_node("Art").texture = POSES["shocked"]
		get_node("Glow").texture = POSES["shocked"]
	elif name == "happy":
		get_node("Art").texture = POSES["happy"]
		get_node("Glow").texture = POSES["happy"]
	elif name == "troll":
		get_node("Art").texture = POSES["troll"]
		get_node("Glow").texture = POSES["troll"]
	elif name == "evil":
		get_node("Art").texture = POSES["evil"]
		get_node("Glow").texture = POSES["evil"]


func beam(i: int) -> Node:
	if i == 0:
		return get_node("../BeamTop")
	elif i == 1:
		return get_node("../BeamMid")
	else:
		return get_node("../BeamBottom")


func show_hp() -> void:
	get_node("../Bar/Label").text = "larry hp: " + str(hp)
	get_node("../Bar/Fill").size.x = 180.0 * hp / 3.0


func run() -> void:
	await get_tree().create_timer(1.8).timeout

	while hp > 0:
		if hp == 3:
			await phase1()
		elif hp == 2:
			await phase2()
		elif hp == 1:
			await phase3()
	await defeat()


func volley(lanes: Array, tele: float) -> void:
	pose("smirk")
	for i in range(lanes.size()):
		beam(lanes[i]).warn(tele)
	await get_tree().create_timer(tele).timeout

	pose("angry")
	for i in range(lanes.size()):
		beam(lanes[i]).fire(0.7)
	await get_tree().create_timer(0.7).timeout


func sweep_one(i: int, delay: float, tele: float) -> void:
	await get_tree().create_timer(delay).timeout
	beam(i).warn(tele)
	await get_tree().create_timer(tele).timeout
	pose("angry")
	beam(i).fire(0.5)


func sweep(tele: float) -> void:
	pose("smirk")
	sweep_one(0, 0.0, tele)
	sweep_one(1, 0.5, tele)
	sweep_one(2, 1.0, tele)
	await get_tree().create_timer(2 * 0.5 + tele + 0.5).timeout


func window(time: float) -> void:
	open = true
	hit = false
	pose("idle")
	get_node("Glow").show()
	var left := time
	while left > 0.0 and hit == false:
		await get_tree().process_frame
		left = left - get_process_delta_time()
	open = false
	get_node("Glow").hide()
	if hit == true:
		await get_tree().create_timer(1.0).timeout


func phase1() -> void:
	if round1 % 3 == 0:
		await volley([2], 1.0)
		await get_tree().create_timer(0.6).timeout
		await volley([0], 1.0)
		await get_tree().create_timer(0.6).timeout
	elif round1 % 3 == 1:
		await volley([0], 1.0)
		await get_tree().create_timer(0.6).timeout
		await volley([1], 1.0)
		await get_tree().create_timer(0.6).timeout
	else:
		await volley([1], 1.0)
		await get_tree().create_timer(0.6).timeout
		await volley([2], 1.0)
		await get_tree().create_timer(0.6).timeout
	round1 = round1 + 2
	await window(4.0)


func phase2() -> void:
	if taunted2 == false:
		taunted2 = true
		pose("troll")
		await get_tree().create_timer(1.3).timeout

	if round2 % 3 == 0:
		await volley([1, 2], 0.8)
		await get_tree().create_timer(0.6).timeout
		await volley([0, 2], 0.8)
		await get_tree().create_timer(0.6).timeout
	elif round2 % 3 == 1:
		await volley([0, 2], 0.8)
		await get_tree().create_timer(0.6).timeout
		await volley([0, 1], 0.8)
		await get_tree().create_timer(0.6).timeout
	else:
		await volley([0, 1], 0.8)
		await get_tree().create_timer(0.6).timeout
		await volley([1, 2], 0.8)
		await get_tree().create_timer(0.6).timeout
	round2 = round2 + 2
	await window(3.5)


func phase3() -> void:
	if taunted3 == false:
		taunted3 = true
		pose("evil")
		await get_tree().create_timer(1.3).timeout

	await sweep(0.6)
	await get_tree().create_timer(0.5).timeout
	await volley([0, 2], 0.6)
	await get_tree().create_timer(0.4).timeout
	await window(3.0)


func knock() -> void:
	if cat.dead == true:
		return

	cat.set_physics_process(false)
	cat.bounce()
	var tw := create_tween().set_parallel()
	tw.tween_property(cat, "global_position:x", 232.0, 0.45)
	tw.tween_property(cat, "global_position:y", 150.0, 0.45)
	await tw.finished
	cat.velocity = Vector2.ZERO
	cat.set_physics_process(true)


func _on_face(body: Node2D) -> void:
	if body.is_in_group("cat") == false:
		return
	if body.dead == true:
		return

	if open == true and hit == false:
		hit = true
		hp = hp - 1
		show_hp()
		pose("shocked")
	knock()


func _on_cat_died() -> void:
	if done == true:
		return

	pose("happy")
	await get_tree().create_timer(0.8).timeout
	if open == false:
		pose("smirk")


func defeat() -> void:
	done = true
	pose("shocked")
	get_node("Glow").hide()
	await get_tree().create_timer(1.5).timeout
	hide()
	get_node("../Goal").show()
	get_node("../Goal").set_deferred("monitoring", true)
