extends CharacterBody2D


@export var marker_a: Marker2D
@export var marker_b: Marker2D
@export var vision_pivot: Node2D
@export var sprite: Sprite2D
@export var speed := 100.0

const ARRIVAL_DISTANCE: float = 10.0
var _target_position: Vector2


func _ready() -> void:
	_target_position = marker_b.global_position


func _physics_process(_delta: float) -> void:
	var direction := global_position.direction_to(_target_position)
	velocity = direction * speed
	move_and_slide()
	
	if velocity.length() > 0.0:
		vision_pivot.rotation = velocity.angle()
		
		if velocity.x < 0:
			sprite.flip_h = true
		elif velocity.x > 0:
			sprite.flip_h = false
	
	if global_position.distance_to(_target_position) < ARRIVAL_DISTANCE:
		if _target_position == marker_a.global_position:
			_target_position = marker_b.global_position
		else:
			_target_position = marker_a.global_position
