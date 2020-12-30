extends KinematicBody2D

#Jump 
export var fallMult = 50
export var lowJumpMultiplier = 700
export var jumpVelocity = 300 #Jump height

#Physics
var velocity = Vector2()
export var gravity = 8

func _ready():
	$Camera2D.make_current()

func _physics_process(delta):

	#Applying gravity to player
	velocity.y += gravity 

	#Jump Physics
	if velocity.y > 0:
		velocity += Vector2.UP * (-9.81) * (fallMult) * delta

	elif velocity.y < 0 && Input.is_action_just_released("Jump"): #Jump key released while in ascent 
		velocity += Vector2.UP * (-9.81) * (lowJumpMultiplier) * delta #Jump Height depends on how long you will hold key

	if is_on_floor():
		if Input.is_action_just_pressed("Jump"): 
			$AnimationPlayer.play("Jump")
			velocity = Vector2.UP * jumpVelocity #Normal Jump action
		else:
			$AnimationPlayer.play("Run")

	velocity = move_and_slide(velocity, Vector2(0,-1))  
