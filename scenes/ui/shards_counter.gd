extends CanvasLayer


@export var label: Label


func _ready() -> void:
	State.collected_shard.connect(_on_collected_shard)


func _on_collected_shard() -> void:
	label.text = str(State.shards_collected) + "/5"
