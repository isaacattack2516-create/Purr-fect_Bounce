extends CanvasLayer

signal retry
signal next


func _ready() -> void:
	$LostPanel/Box/Retry.pressed.connect(retry.emit)
	$WinPanel/Box/Next.pressed.connect(next.emit)


func set_lives(n: int) -> void:
	$Lives.text = "Lives: %d" % n


func set_time(t: float) -> void:
	$Time.text = "%02d:%04.1f" % [floori(t / 60.0), fmod(t, 60.0)]


func show_lost() -> void:
	$LostPanel.show()
	$LostPanel/Box/Retry.grab_focus()


func show_win(t: float, lives: int, last: bool) -> void:
	set_time(t)
	$WinPanel/Box/Result.text = "Time %s\nLives left %d" % [$Time.text, lives]
	$WinPanel/Box/Next.text = "Play again" if last else "Next level"
	$WinPanel.show()
	$WinPanel/Box/Next.grab_focus()
