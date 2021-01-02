extends Area2D


export var value = 20
signal picked_up(value)

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Pickup_Idle")
	self.connect("body_entered", self, "_on_player_body_entered")
	
	var game_manager = get_tree().get_root().find_node("Game_Manager", true, false)
	self.connect("picked_up", game_manager, "pickup")


func _process(_delta):
	pass


func _on_player_body_entered(body):
	print("collision")
	if body.is_in_group("Player"):
		print("Picked Up!")
		emit_signal("picked_up", value)
		get_parent().remove_child(self)
