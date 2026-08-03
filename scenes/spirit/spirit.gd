extends CharacterBody2D


signal player_caught


@export var marker_a: Marker2D
@export var marker_b: Marker2D
@export var vision_pivot: Node2D
@export var sprite: Sprite2D

@export var vision_outline: Line2D
@export var vision_collision: CollisionPolygon2D

# --- Vision shape tuning ---
@export var vision_range: float = 150.0
@export var vision_half_angle_deg: float = 25.0
@export var personal_radius: float = 40.0
@export var blend_angle_deg: float = 20.0
@export var shape_segments: int = 48

# Physics layer the walls live on (matches "FloorAndWalls" = layer 1 in your project)
@export_flags_2d_physics var wall_collision_mask: int = 1

const ARRIVAL_DISTANCE: float = 16.0
const CAUGHT_DELAY: float = 1.0
const BLINK_INTERVAL: float = 0.08

var _target_position: Vector2
var _is_alerted := false
var _player_in_area := false
var _player_ref: Node2D = null

var speed := 60.0


func _ready() -> void:
	_target_position = marker_b.global_position
	_build_vision_collision()  # static broad-phase shape, built once


func _radius_for_local_angle(angle: float, half_fov: float, blend: float) -> float:
	var abs_angle: float = abs(angle)
	if abs_angle <= half_fov:
		return vision_range
	elif abs_angle <= half_fov + blend:
		var t := (abs_angle - half_fov) / blend
		t = t * t * (3.0 - 2.0 * t)  # smoothstep, avoids a visible kink
		return lerp(vision_range, personal_radius, t)
	else:
		return personal_radius


func _build_vision_collision() -> void:
	if not vision_collision:
		return

	var half_fov := deg_to_rad(vision_half_angle_deg)
	var blend := deg_to_rad(blend_angle_deg)
	var points := PackedVector2Array()

	for i in shape_segments:
		var angle := (TAU * i / shape_segments) - PI
		var radius := _radius_for_local_angle(angle, half_fov, blend)
		points.append(Vector2(cos(angle), sin(angle)) * radius)

	vision_collision.polygon = points


func _update_vision_outline() -> void:
	# Rebuilt every frame: casts a ray for each outline point and clips it
	# against walls, so the VISUAL shape can never appear to pass through them.
	if not vision_outline:
		return

	var space_state := get_world_2d().direct_space_state
	var half_fov := deg_to_rad(vision_half_angle_deg)
	var blend := deg_to_rad(blend_angle_deg)
	var points := PackedVector2Array()

	for i in shape_segments:
		var local_angle := (TAU * i / shape_segments) - PI
		var max_radius := _radius_for_local_angle(local_angle, half_fov, blend)

		var global_dir := Vector2.RIGHT.rotated(vision_pivot.global_rotation + local_angle)
		var target := global_position + global_dir * max_radius

		var query := PhysicsRayQueryParameters2D.create(global_position, target)
		query.collision_mask = wall_collision_mask
		query.exclude = [self]
		var result := space_state.intersect_ray(query)

		var point_global: Vector2 = result.position if result else target
		points.append(vision_outline.to_local(point_global))

	points.append(points[0])  # close the loop
	vision_outline.points = points
	vision_outline.default_color = Color.WHITE
	vision_outline.width = 2.0


func _physics_process(_delta: float) -> void:
	if _is_alerted:
		return

	var direction := global_position.direction_to(_target_position)
	velocity = direction * speed
	move_and_slide()

	if velocity.length() > 0.0:
		vision_pivot.rotation = velocity.angle()

		if velocity.x < -1.0:
			sprite.flip_h = true
		elif velocity.x > 1.0:
			sprite.flip_h = false

	if global_position.distance_to(_target_position) < ARRIVAL_DISTANCE:
		_target_position = marker_a.global_position if _target_position == marker_b.global_position else marker_b.global_position

	_update_vision_outline()

	if _player_in_area and _has_line_of_sight_to_player():
		_catch_player()


func _has_line_of_sight_to_player() -> bool:
	if not _player_ref:
		return false

	var space_state := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(
		global_position,
		_player_ref.global_position
	)
	query.collision_mask = wall_collision_mask
	query.exclude = [self]

	var result := space_state.intersect_ray(query)
	return result.is_empty()


func _on_vision_cone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_area = true
		_player_ref = body


func _on_vision_cone_body_exited(body: Node2D) -> void:
	if body == _player_ref:
		_player_in_area = false
		_player_ref = null


func _catch_player() -> void:
	if _is_alerted:
		return

	_is_alerted = true
	velocity = Vector2.ZERO
	player_caught.emit()
	await _play_caught_feedback()
	get_tree().call_deferred("reload_current_scene")


func _play_caught_feedback() -> void:
	var blinks := int(CAUGHT_DELAY / BLINK_INTERVAL)
	for i in blinks:
		if vision_outline:
			vision_outline.visible = not vision_outline.visible
		await get_tree().create_timer(BLINK_INTERVAL).timeout
	if vision_outline:
		vision_outline.visible = true
