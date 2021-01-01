extends Node2D

var obj_available: Array = []
var obj_in_scene: Array = []
var pool_position = Vector2(2000, 2000)

export var dir_path = "res://Scenes/Mountains/Front_Layer/"

export var avg_gap_size = 100
export var mountain_gap_range = 100

var rng = RandomNumberGenerator.new()

var obj_copies = 30

var default_spawn_position = Vector2(1000, 150)

func _ready():

	
	var files = files_in_directory(dir_path)
	pool_objects(files, obj_copies)
	yield(obj_available.back(), "ready")
	first_spawn()
	print(obj_in_scene)

func first_spawn():
	for _i in range(1, 30):
		place_mountain(select_rand_index())
	#print("first spawn over")
	
func select_rand_index():
	rng.randomize()
	return rng.randi_range(0, len(obj_available)-1)


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
			var object: Sprite = resource.instance()
			object.global_position = pool_position
			if (object.connect("this_off_screen", self, "mountain_off_screen") != OK):
				print("Error connecting signal from mountain nodes")
			obj_available.append(object)
			get_parent().call_deferred('add_child_below_node', self, object)


func get_random_gap(gap_size, gap_range):
	rng.randomize()
	return rng.randf_range(gap_size - gap_range, gap_size + gap_range)

func place_mountain(index_select):
	var object = obj_available[index_select]
	object.global_position = get_spawn_position(object, avg_gap_size)
	object.vel_multiplier = 1
	obj_available.remove(index_select)
	obj_in_scene.append(object)
	#print("mountain placed")
	

func get_spawn_position(obj_to_spawn, gap_size):
	if obj_in_scene.size() <= 0:
		return default_spawn_position
	else:
		var previous_obj = obj_in_scene.back()
		var dist_from_prev = (obj_to_spawn.halfwidth) + (previous_obj.halfwidth) + get_random_gap(gap_size, mountain_gap_range)
		return Vector2(dist_from_prev + previous_obj.global_position.x, default_spawn_position.y)
		
func mountain_off_screen(destroyed_obj):
	move_to_pool(destroyed_obj)
	place_mountain(select_rand_index())
	#print("mountain off screen")


func move_to_pool(destroyed_obj):
	destroyed_obj.vel_multiplier = 0
	destroyed_obj.global_position = pool_position
	var index = obj_in_scene.find(destroyed_obj) ### This can and probably should be replaced
	obj_in_scene.remove(index)					#### with a pop_front()
	obj_available.append(destroyed_obj)
