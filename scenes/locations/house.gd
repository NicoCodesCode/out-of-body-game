extends Node2D


@export var music: AudioStreamPlayer
@export var player: CharacterBody2D


func _ready() -> void:
	State.is_about_to_enter_bathroom_mirror.connect(_on_is_about_to_enter_bathroom_mirror)
	State.entered_bathroom_mirror.connect(_on_entered_bathroom_mirror)


func _on_is_about_to_enter_bathroom_mirror() -> void:
	music.stop()


func _on_entered_bathroom_mirror() -> void:
	GameManager.go_to_scene(GameManager.LEVEL_1_SCENE)
