extends Area2D


export var value = 20
signal picked_up(value)

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Pickup_Idle")
	if self.connect("body_entered", self, "_on_player_entered") != OK:
		print("issue connecting body_entered in pickup")
	
	var game_manager = get_tree().get_root().find_node("Game_Manager", true, false)
	if self.connect("picked_up", game_manager, "pickup") != OK:
		print("issue connecting picked_up in pickup")


func _process(_delta):
	pass


func _on_player_entered(body):
	print("collision")
	if body.is_in_group("Player"):
		print("Picked Up!")
		emit_signal("picked_up", value)
		global_position = Vector2(1000, 1000)
