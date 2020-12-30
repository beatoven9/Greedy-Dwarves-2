extends Node2D

export var dir_path = "res://Scenes/Ground_Parts/"

var obj_pool: Array = []
var obj_available: Array = []
var obj_in_scene: Array = []

var pool_position = Vector2(2000, 2000)
var default_spawn_position = Vector2(500, 150)

var horizontal_velocity: int
export var horizontal_velocity_multiplier = 10
export var plateau_gap_size = 50
export var plateau_spawn_y = 150

var rng = RandomNumberGenerator.new()

var obj_copies = 10

func _ready():
	var files = files_in_directory(dir_path)
	pool_objects(files, obj_copies)
	yield(obj_available.back(), "ready")
	first_spawn()


func _process(_delta):
	pass
		

func first_spawn():
	for _i in range(1, 10):
		place_plateau(select_rand_index())
	
	
func files_in_directory(path):
	var files = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		while(true):
			var file = dir.get_next()
			if file == "":
				break
			elif not file.begins_with("."):
				files.append(path + file)
		return files
	else:
		print("an error occurred while accessing the path:", path)


func pool_objects(files, num_copies):
	for file in files:
		var resource = load(file)
		for i in num_copies:
			var object: KinematicBody2D = resource.instance()
			object.global_position = pool_position
			if (object.connect("off_screen", self, "plateau_off_screen") != OK):
				print("Error connecting signal from tilemap nodes")
			obj_pool.append(object)
			obj_available.append(object)
			get_parent().call_deferred('add_child_below_node', self, object)


#Called when signal is recieved from Ground_Tile.gd that a ground tile has gone off screen
func plateau_off_screen(destroyed_obj):
	print("Signal recieved")
	move_to_pool(destroyed_obj)
	place_plateau(select_rand_index())


func move_to_pool(destroyed_obj):
	destroyed_obj.vel_multiplier = 0
	destroyed_obj.global_position = pool_position
	var index = obj_in_scene.find(destroyed_obj) ### This can and probably should be replaced
	obj_in_scene.remove(index)					#### with a pop_front()
	obj_available.append(destroyed_obj)

func select_rand_index():
	rng.randomize()
	return rng.randi_range(0, len(obj_available)-1)


func get_spawn_position(obj_to_spawn, gap_size):
	if obj_in_scene.size() <= 0:
		return default_spawn_position
	else:
		var previous_obj = obj_in_scene.back()
		var dist_from_prev = (obj_to_spawn.halfwidth) + (previous_obj.halfwidth) + gap_size
		return Vector2(dist_from_prev + previous_obj.global_position.x, plateau_spawn_y)
		
		
func place_plateau(index_select): 
	var object = obj_available[index_select]
	object.global_position = get_spawn_position(object, plateau_gap_size)
	object.vel_multiplier = 1
	obj_available.remove(index_select)
	obj_in_scene.append(object)
