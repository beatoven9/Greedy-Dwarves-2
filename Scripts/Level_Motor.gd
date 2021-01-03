extends Node2D

#### paths to Scene Folders
export var plateau_path = "res://Scenes/Plateaus/"
export var platform_path = "res://Scenes/Platforms/"
export var pickup_path = "res://Scenes/Pickups/"
export var front_mount_path = "res://Scenes/Mountains/Front_Layer/"
export var mid_mount_path = "res://Scenes/Mountains/Mid_Layer/"
export var back_mount_path = "res://Scenes/Mountains/Back_Layer/"


##### pools
	## PLATEAUS
var plateaus_available: Array = []
var plateaus_in_scene: Array = []
export var avg_plateau_gap_size = 150
export var plateau_gap_range = 70
export var avg_plateau_spawn_y = 300
export var plateau_y_range = 50
export var max_gap_without_platform = 150
var plateau_copies = 10

	## PLATFORMS
var platforms_available: Array = []
var platforms_in_scene: Array = []
var platform_copies = 40

	## PICKUPS
var pickups_available: Array = []
var pickups_in_scene: Array = []
var pickup_copies = 10
var pickup_default_x_pos = 900
export var y_range = Vector2(0, 100)

	## FRONT_MOUNTAINS
var front_mounts_available: Array = []
var front_mounts_in_scene: Array = []
var front_mount_copies = 15
var avg_front_mount_gap = 400
var front_y_offset = 400

	## MID_MOUNTAINS
var mid_mounts_available: Array = []
var mid_mounts_in_scene: Array = []
var mid_mount_copies = 15
var avg_mid_mount_gap = 500
var mid_y_offset = 350

	## BACK_MOUNTAINS
var back_mounts_available: Array = []
var back_mounts_in_scene: Array = []
var back_mount_copies = 15
var avg_back_mount_gap = 600
var back_y_offset = 300

	## general mountain stuff
var default_mountain_spawn_position = Vector2(0, 400)
var mountain_gap_range = 300

	## general pool stuff
var pool_position = Vector2(2000, 2000)
var default_spawn_position = Vector2(0, 300)


#var horizontal_velocity: int
export var horizontal_velocity_multiplier = 10

### velocity variables
const ZERO_VEL = 0
const NORMAL_SPEED = 1

var front_mount_vel = .9
var mid_mount_vel = .7
var back_mount_vel = .5

### misc vars
var first_jump = false
var rng = RandomNumberGenerator.new()
var time = 0

enum {PLATEAU, PLATFORM, PICKUP, FRONT_MOUNT, MID_MOUNT, BACK_MOUNT}

func _ready():

	var plateau_files = files_in_directory(plateau_path)
	pool_objects(plateau_files, plateau_copies, plateaus_available, PLATEAU)
	yield(plateaus_available.back(), "ready")
	
	var platform_files = files_in_directory(platform_path)
	pool_objects(platform_files, platform_copies, platforms_available, PLATFORM)
	yield(platforms_available.back(), "ready")
	first_plateau_spawn()
	
	var pickup_files = files_in_directory(pickup_path)
	pool_objects(pickup_files, pickup_copies, pickups_available, PICKUP)
	yield(pickups_available.back(), "ready")
	
	var front_mount_files = files_in_directory(front_mount_path)
	pool_objects(front_mount_files, front_mount_copies, front_mounts_available, FRONT_MOUNT)
	
	var mid_mount_files = files_in_directory(mid_mount_path)
	pool_objects(mid_mount_files, mid_mount_copies, mid_mounts_available, MID_MOUNT)
	
	var back_mount_files = files_in_directory(back_mount_path)
	pool_objects(back_mount_files, back_mount_copies, back_mounts_available, BACK_MOUNT)	
	yield(back_mounts_available.back(), "ready")
	
	first_mount_spawn(20)
	#first_mount_spawn(20, MID_MOUNT)
	#first_mount_spawn(20, BACK_MOUNT)
	
	

func _process(_delta):
#	time += delta
#	if time >= 4:
#		place_pickup()
#		time = 0
	if Input.is_action_just_pressed("Jump") && first_jump == false:
		first_jump = true
		place_pickup()		

func first_plateau_spawn():
	for _i in range(1, 30):
		place_plateau()
	
func first_mount_spawn(x):
	for _i in range(1, x):
		place_mountain(front_mounts_available, front_mounts_in_scene, avg_front_mount_gap, front_mount_vel, front_y_offset)
		place_mountain(mid_mounts_available, mid_mounts_in_scene, avg_mid_mount_gap, mid_mount_vel, mid_y_offset)
		place_mountain(back_mounts_available, back_mounts_in_scene, avg_back_mount_gap, back_mount_vel, back_y_offset)
	
func first_pickup_spawn():
		place_pickup()

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


func pool_objects(files, num_copies, objs_available, obj_type):
	for file in files:
		var resource = load(file)
		for i in num_copies:
			var object = resource.instance()
			object.global_position = pool_position
			match obj_type:
				PLATEAU:
					if (object.connect("off_screen", self, "plateau_off_screen") != OK):
						print("Error connecting signal from tilemap nodes")
				PLATFORM:
					if (object.connect("off_screen", self, "platform_off_screen") != OK):
						print("Error connecting signal from platform nodes")
				PICKUP:
					if (object.connect("off_screen", self, "pickup_off_screen") != OK):
						print("Error connecting signal from pickup nodes")
				FRONT_MOUNT:
					if (object.connect("off_screen", self, "front_mount_off_screen") != OK):
						print("Error connecting signal from front_mount nodes")
				MID_MOUNT:
					if (object.connect("off_screen", self, "mid_mount_off_screen") != OK):
						print("Error connecting signal from mid_mount nodes")
				BACK_MOUNT:
					if (object.connect("off_screen", self, "back_mount_off_screen") != OK):
						print("Error connecting signal from back_mount nodes")
				_:
					print("object type not yet implemented")
			objs_available.append(object)
			get_parent().call_deferred('add_child_below_node', self, object)


###
### off_screen functions
func plateau_off_screen(destroyed_obj):
	move_to_pool(destroyed_obj, plateaus_in_scene, plateaus_available)
	place_plateau()

func platform_off_screen(destroyed_obj):
	move_to_pool(destroyed_obj, platforms_in_scene, platforms_available)

func front_mount_off_screen(destroyed_obj):
	move_to_pool(destroyed_obj, front_mounts_in_scene, front_mounts_available)
	place_mountain(front_mounts_available, front_mounts_in_scene, avg_front_mount_gap, front_mount_vel, front_y_offset)

func mid_mount_off_screen(destroyed_obj):
	move_to_pool(destroyed_obj, mid_mounts_in_scene, mid_mounts_available)
	place_mountain(mid_mounts_available, mid_mounts_in_scene, avg_mid_mount_gap, mid_mount_vel, mid_y_offset)
	
func back_mount_off_screen(destroyed_obj):
	move_to_pool(destroyed_obj, back_mounts_in_scene, back_mounts_available)
	place_mountain(back_mounts_available, back_mounts_in_scene, avg_back_mount_gap, back_mount_vel, back_y_offset)

func pickup_off_screen(destroyed_obj):
	move_to_pool(destroyed_obj, pickups_in_scene, pickups_available)
	place_pickup()

####
### object placement functions
func place_plateau():
	var index_select = select_rand_index(plateaus_available)
	var object = plateaus_available[index_select]
	var spawn_location = get_plateau_spawn_position(object, avg_plateau_gap_size)
	object.global_position = spawn_location
	object.vel_multiplier = NORMAL_SPEED
	plateaus_available.remove(index_select)
	plateaus_in_scene.append(object)

	
func place_mountain(objs_available, objs_in_scene, avg_gap, obj_vel, y_offset):
	var object
	var spawn_position
	var index_select = select_rand_index(objs_available)
	object = objs_available[index_select]
	spawn_position = get_mountain_spawn_position(object, objs_in_scene, avg_gap, y_offset)
	objs_available.remove(index_select)
	objs_in_scene.append(object)
	object.vel_multiplier = NORMAL_SPEED * obj_vel
	object.global_position = spawn_position


func place_platform(prev_obj, next_obj):
	var platform = platforms_available.pop_back() 
	var platform_pos = Vector2( ( ( ( next_obj.x - prev_obj.x ) / 2 ) + prev_obj.x), ( ( ( next_obj.y - prev_obj.y ) / 2 ) + prev_obj.y ) )
	platform.global_position = platform_pos
	platform.vel_multiplier = 1
	platforms_in_scene.push_back(platform)


func place_pickup():
	print("Pickup placed")
	var index_select = select_rand_index(pickups_available)
	var object = pickups_available[index_select]
	rng.randomize()
	var y_position = rng.randf_range(y_range.x, y_range.y)
	object.global_position = Vector2(pickup_default_x_pos, y_position)
	object.vel_multiplier = 1
	pickups_available.remove(index_select)
	pickups_in_scene.push_back(object)

### placement helpers
func get_random_gap(gap_size, gap_range):
	rng.randomize()
	return rng.randf_range(gap_size - gap_range, gap_size + gap_range)

func get_random_y_spawn(avg_y_pos, y_pos_range):
	rng.randomize()
	return rng.randf_range(avg_y_pos - y_pos_range, avg_y_pos + y_pos_range)


func get_plateau_spawn_position(obj_to_spawn, gap_size):
	if plateaus_in_scene.size() <= 0:
		return default_spawn_position
	else:
		var previous_obj = plateaus_in_scene.back()
		var dist_from_prev = (obj_to_spawn.halfwidth) + (previous_obj.halfwidth) + get_random_gap(gap_size, plateau_gap_range)
		var spawn_location = Vector2(dist_from_prev + previous_obj.global_position.x, get_random_y_spawn(avg_plateau_spawn_y, plateau_y_range))
		var inner_corner_previous = Vector2(previous_obj.global_position.x + previous_obj.halfwidth, previous_obj.global_position.y)
		var inner_corner_current = Vector2( ( spawn_location.x - obj_to_spawn.halfwidth ), spawn_location.y)
		var plateau_distance = inner_corner_previous.distance_to(inner_corner_current)

		if plateau_distance > max_gap_without_platform: 
			place_platform(inner_corner_previous, inner_corner_current) 
		return spawn_location
		
func get_mountain_spawn_position(obj_to_spawn, objs_in_scene, gap_size, y_offset):
	if objs_in_scene.size() <= 0:
		return Vector2(default_mountain_spawn_position.x, y_offset)
	else:
		var previous_obj = objs_in_scene.back()
		var dist_from_prev = (obj_to_spawn.halfwidth) + (previous_obj.halfwidth) + get_random_gap(gap_size, mountain_gap_range)
		var spawn_location = Vector2(dist_from_prev + previous_obj.global_position.x, y_offset)
		return spawn_location


####
### misc helper functions
func move_to_pool(destroyed_obj, objs_in_scene, objs_available):
	destroyed_obj.vel_multiplier = 0
	destroyed_obj.global_position = pool_position
	var index = objs_in_scene.find(destroyed_obj) ### This can and probably should be replaced
	objs_in_scene.remove(index)					#### with a pop_front()
	objs_available.append(destroyed_obj)

func select_rand_index(objs_available):
	rng.randomize()
	return rng.randi_range(0, len(objs_available)-1)


		

