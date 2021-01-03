extends MarginContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.




func _on_Game_Manager_update_score_display(score):
	print("Score updated")
	$Number.text = str(score)
