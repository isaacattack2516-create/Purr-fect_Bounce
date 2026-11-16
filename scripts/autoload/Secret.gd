extends CanvasLayer

const LEVELS := [
	["Level 1", "res://scenes/levels/Level1.tscn"],
	["Level 2", "res://scenes/levels/Level2.tscn"],
	["Level 3", "res://scenes/levels/Level3.tscn"],
	["Level 4", "res://scenes/levels/Level4.tscn"],
	["Boss", "res://scenes/levels/BossLevel.tscn"],
	["Larry", "res://scenes/levels/LarryFight.tscn"],
]

var typed := ""
var back: Control
var panel := PanelContainer.new()
var box := VBoxContainer.new()


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.hide()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	panel.add_child(box)
	add_child(panel)

	var title := Label.new()
	title.text = "Level select"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	for level in LEVELS:
		var button := Button.new()
		button.text = level[0]
		button.pressed.connect(pick.bind(level[1]))
		box.add_child(button)


func _input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return

	if panel.visible and key.keycode == KEY_ESCAPE:
		close()
		return

	if key.unicode == 0:
		return

	typed = (typed + char(key.unicode).to_lower()).right(5)
	if typed == "salah":
		typed = ""
		if panel.visible:
			close()
		else:
			open()


func open() -> void:
	back = get_viewport().gui_get_focus_owner()
	panel.show()
	get_tree().paused = true
	box.get_child(1).grab_focus()


func close() -> void:
	panel.hide()
	get_tree().paused = false
	if back:
		back.grab_focus()


func pick(path: String) -> void:
	back = null
	close()
	get_tree().change_scene_to_file(path)
