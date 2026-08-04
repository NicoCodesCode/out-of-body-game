extends CharacterBody2D


@export var animation_tree: AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

@export var interaction_detector: Area2D

const SPEED = 150.0

var MAX_PRESENCE := 100.0
var _soul_presence := MAX_PRESENCE
var _drain_rate := 10.0
var _recharge_rate := 30.0

var is_in_house := true
var is_in_safe_zone := false


func _ready() -> void:
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
	animation_tree.active = true


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		var actionables: Array[Area2D] = interaction_detector.get_overlapping_areas()
		if actionables.size() > 0:
			actionables[0].action()
			return


func _physics_process(delta: float) -> void:
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if input_direction != Vector2.ZERO:
		velocity = input_direction * SPEED
		
		animation_tree.set("parameters/Idle/blend_position", input_direction)
		animation_tree.set("parameters/Walk/blend_position", input_direction)
		
		state_machine.travel("Walk")
	else:
		velocity = Vector2.ZERO
		state_machine.travel("Idle")
	
	move_and_slide()
	
	_manage_soul_presence(delta)


func _stop_player() -> void:
	velocity = Vector2.ZERO
	state_machine.travel("Idle")
	set_physics_process(false)


func _manage_soul_presence(delta: float) -> void:
	if is_in_house:
		return
	
	if is_in_safe_zone:
		_soul_presence = clampf(_soul_presence + _recharge_rate * delta, 0.0, MAX_PRESENCE)
	else:
		_soul_presence = clampf(_soul_presence - _drain_rate * delta, 0.0, MAX_PRESENCE)
	
	print("Soul Presence: ", _soul_presence)
	
	if _soul_presence == 0:
		get_tree().reload_current_scene()


func _on_dialogue_started(_resource: DialogueResource) -> void:
	_stop_player()


func _on_dialogue_ended(_resource: DialogueResource) -> void:
	set_physics_process(true)


func _on_spirit_player_caught() -> void:
	State.shards_collected = 0
	_stop_player()
