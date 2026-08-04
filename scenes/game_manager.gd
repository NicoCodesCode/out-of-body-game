extends Node


const HOUSE_SCENE: PackedScene = preload("res://scenes/locations/house.tscn")
const LEVEL_1_SCENE: PackedScene = preload("res://scenes/locations/level_1.tscn")

var pending_spawn_point: String = ""

const CUT_HOLD_DURATION := 1.0

@export var cut_rect: ColorRect


func _ready() -> void:
	cut_rect.color = Color.BLACK
	cut_rect.visible = false


func go_to_scene(scene: PackedScene) -> void:
	cut_rect.visible = true
	await get_tree().create_timer(CUT_HOLD_DURATION).timeout

	get_tree().change_scene_to_packed(scene)
	await get_tree().process_frame

	cut_rect.visible = false
