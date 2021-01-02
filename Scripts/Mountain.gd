extends Sprite

signal off_screen(destroyed_obj)

export var velocity = -100
var vel_multiplier = 0
var halfwidth 

var viewport_x = -500

func _ready():
	halfwidth = self.region_rect.size.x/2

	
func _process(delta):
	if global_position.x <= viewport_x:
		emit_signal("off_screen", self)
	position += velocity * Vector2(1,0) * vel_multiplier * delta


