extends CharacterBody2D


const SPEED = 400.0

var MAX_PRESENCE := 100.0
var _soul_presence := MAX_PRESENCE
var _drain_rate := 10.0
var _recharge_rate := 30.0
var _is_in_safe_zone := false


func _physics_process(delta: float) -> void:
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_direction * SPEED
	
	move_and_slide()
	
	if _is_in_safe_zone:
		_soul_presence = clampf(_soul_presence + _recharge_rate * delta, 0.0, MAX_PRESENCE)
	else:
		_soul_presence = clampf(_soul_presence - _drain_rate * delta, 0.0, MAX_PRESENCE)
	
	modulate.a = _soul_presence / 100
	print("Soul Presence: ", _soul_presence)
	
	if _soul_presence == 0:
		get_tree().reload_current_scene()


func _on_safe_zone_body_entered(body: Node2D) -> void:
	if body == self:
		_is_in_safe_zone = true


func _on_safe_zone_body_exited(body: Node2D) -> void:
	if body == self:
		_is_in_safe_zone = false
