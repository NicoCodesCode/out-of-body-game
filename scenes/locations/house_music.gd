extends AudioStreamPlayer


func _ready() -> void:
	State.is_about_to_enter_bathroom_mirror.connect(_on_is_about_to_enter_bathroom_mirror)


func _on_is_about_to_enter_bathroom_mirror() -> void:
	stop()
