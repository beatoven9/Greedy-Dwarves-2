extends Area2D


export var value = 20
signal picked_up(value)

signal off_screen(destroyed_obj)

export var velocity = Vector2(-200, 0)

var viewport_x = -500 # until I can figure out how to reliably find this value
var halfwidth
var vel_multiplier = 0

func _ready():
	halfwidth = $Sprite.region_rect.size.x/2

	$AnimationPlayer.play("Pickup_Idle")
	if self.connect("body_entered", self, "_on_player_entered") != OK:
		print("issue connecting body_entered in pickup")

	var game_manager = get_tree().get_root().find_node("Game_Manager", true, false)
	if self.connect("picked_up", game_manager, "pickup") != OK:
		print("issue connecting picked_up to game_manager in pickup")


func _process(delta):
	if global_position.x <= viewport_x - halfwidth:
		emit_signal("off_screen", self)
	position += velocity * Vector2(1,0) * vel_multiplier * delta


func _on_player_entered(body):
	if body.is_in_group("Player"):
		emit_signal("picked_up", value)
		emit_signal("off_screen", self)
