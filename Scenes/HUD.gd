extends CanvasLayer


var score_label

func _ready():
	score_label = get_node("TopBar/Spacer/Coins/Score")
	score_label.text = str(0)
	
	var game_manager = get_tree().get_root().find_node("Game_Manager", true, false)
	if game_manager.connect("update_score_display", self, "update_score") != OK:
		print("issue connecting picked_up in pickup")

func update_score(value):
	score_label.text = str(value)
