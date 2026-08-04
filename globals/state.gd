extends Node


@warning_ignore("unused_signal")
signal is_about_to_enter_bathroom_mirror

@warning_ignore("unused_signal")
signal entered_bathroom_mirror

@warning_ignore("unused_signal")
signal collected_shard


var shards_collected := 0

var has_seen_bathroom_mirror_dialogue := false
var has_seen_entrance_mirror_dialogue := false
var has_seen_full_length_mirror_dialogue := false
