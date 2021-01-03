extends Area2D


signal player_has_died


# Called when the node enters the scene tree for the first time.
func _ready():
	if self.connect("body_entered", self, "_on_player_entered") != OK:
		print("issue connecting body_entered in Death_Trigger")
		
	var game_manager = get_tree().get_root().find_node("Game_Manager", true, false)
	if self.connect("player_has_died", game_manager, "game_over") != OK:
		print("issue connecting player_has_died in Death_Trigger")

func _on_player_entered(body):
	if body.is_in_group("Player"):
		print("Player has died")
		emit_signal("player_has_died")

