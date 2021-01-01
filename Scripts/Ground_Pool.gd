extends Node2D

export var plateau_path = "res://Scenes/Ground_Parts/"
export var platform_path = "res://Scenes/Platforms/"


#var obj_pool: Array = []
var plateaus_available: Array = []
var plateaus_in_scene: Array = []

var platforms_available: Array = []
var platforms_in_scene: Array = []

var pool_position = Vector2(2000, 2000)
var default_spawn_position = Vector2(1000, 0)

var horizontal_velocity: int
export var horizontal_velocity_multiplier = 10
export var avg_plateau_gap_size = 90
export var plateau_gap_range = 70

export var max_gap_without_platform = 200

export var avg_plateau_spawn_y = 0
export var plateau_y_range = 50

var rng = RandomNumberGenerator.new()

var plateau_copies = 10
var platform_copies = 20

func _ready():
	var plateau_files = files_in_directory(plateau_path)
	pool_objects(plateau_files, plateau_copies, plateaus_available, true)
	yield(plateaus_available.back(), "ready")
	var platform_files = files_in_directory(platform_path)
	pool_objects(platform_files, platform_copies, platforms_available, false)
	yield(platforms_available.back(), "ready")
	first_plateau_spawn()


func _process(_delta):
	pass
		

func first_plateau_spawn():
	for _i in range(1, 30):
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

### the "is_plateau" parameter really should be an enumeration and we should replace the "if...else" with a switch statement
### this will allow us to repurpose this script to handle the mountains as well
func pool_objects(files, num_copies, objs_available, is_plateau):
	for file in files:
		var resource = load(file)
		for i in num_copies:
			var object: KinematicBody2D = resource.instance()
			object.global_position = pool_position
			if is_plateau:
				if (object.connect("off_screen", self, "plateau_off_screen") != OK):
					print("Error connecting signal from tilemap nodes")
			else:
				if (object.connect("off_screen", self, "platform_off_screen") != OK):
					print("Error connecting signal from tilemap nodes")
#			obj_pool.append(object)
			objs_available.append(object)
			get_parent().call_deferred('add_child_below_node', self, object)


#Called when signal is recieved from Ground_Tile.gd that a ground tile has gone off screen
func plateau_off_screen(destroyed_obj):
	move_to_pool(destroyed_obj, plateaus_in_scene, plateaus_available)
	place_plateau(select_rand_index())

func platform_off_screen(destroyed_obj):
	print("platform off screen")
	move_to_pool(destroyed_obj, platforms_in_scene, platforms_available)


func move_to_pool(destroyed_obj, objs_in_scene, objs_available):
	destroyed_obj.vel_multiplier = 0
	destroyed_obj.global_position = pool_position
	var index = objs_in_scene.find(destroyed_obj) ### This can and probably should be replaced
	objs_in_scene.remove(index)					#### with a pop_front()
	objs_available.append(destroyed_obj)

func select_rand_index():
	rng.randomize()
	return rng.randi_range(0, len(plateaus_available)-1)

func get_random_gap(gap_size, gap_range):
	rng.randomize()
	return rng.randf_range(gap_size - gap_range, gap_size + gap_range)

func get_random_y_spawn(avg_y_pos, y_pos_range):
	rng.randomize()
	return rng.randf_range(avg_y_pos - y_pos_range, avg_y_pos + y_pos_range)

func get_spawn_position(obj_to_spawn, gap_size):
	if plateaus_in_scene.size() <= 0:
		return default_spawn_position
	else:
		var previous_obj = plateaus_in_scene.back()
		var dist_from_prev = (obj_to_spawn.halfwidth) + (previous_obj.halfwidth) + get_random_gap(gap_size, plateau_gap_range)
		var spawn_location = Vector2(dist_from_prev + previous_obj.global_position.x, get_random_y_spawn(avg_plateau_spawn_y, plateau_y_range))
		var plateau_distance = plateaus_in_scene.back().global_position.distance_to(spawn_location)
		if plateau_distance > max_gap_without_platform: 
			place_platform(previous_obj.global_position, spawn_location) 
		return spawn_location
		
		
func place_plateau(index_select): 
	var object = plateaus_available[index_select]
	var spawn_location = get_spawn_position(object, avg_plateau_gap_size)
	object.global_position = spawn_location
	object.vel_multiplier = 1
	plateaus_available.remove(index_select)
	plateaus_in_scene.append(object)

func place_platform(prev_obj, next_obj):
	var platform = platforms_available.pop_back() 
	
	### this formula is calculating distance between the centers of the platform but it should probably be calculating the distance between the two inside corners
	var platform_pos = Vector2( ( ( ( next_obj.x - prev_obj.x ) / 2 ) + prev_obj.x), ( ( ( next_obj.y - prev_obj.y ) / 2 ) + prev_obj.y ) )
	platform.global_position = platform_pos
	platform.vel_multiplier = 1
	platforms_in_scene.push_back(platform)
	
