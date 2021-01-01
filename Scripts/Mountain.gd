extends Sprite


signal this_off_screen(destroyed_obj)

export var velocity = -100
var vel_multiplier = 0
var halfwidth 

func _ready():
	halfwidth = self.region_rect.size.x/2
	
var time = 0
func _process(delta):
	
	if global_position.x <= -1000:
		emit_signal("this_off_screen", self)
	position += velocity * Vector2(1,0) * vel_multiplier * delta


