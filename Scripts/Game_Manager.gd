extends Control


var score = 0
signal update_score_display(score)

func _ready():
	pass


func pickup(value):
	score += value
	print("Score increased by: ", value)
	emit_signal("update_score_display", score)

func update_score_display():
	pass
	
func game_over():
	pass
