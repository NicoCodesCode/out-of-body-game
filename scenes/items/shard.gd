extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		State.shards_collected += 1
		queue_free()
