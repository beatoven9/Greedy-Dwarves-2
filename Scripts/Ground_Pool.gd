extends Node2D

export var dir_path = "res://Scenes/Ground_Parts/"

var obj_pool: Array = []
var obj_available: Array = []
var obj_in_scene: Array = []

var horizontal_velocity: int
export var horizontal_velocity_multiplier = 10

var rng = RandomNumberGenerator.new()

var obj_copies = 10

func _ready():
	var files = files_in_directory(dir_path)
	
	pool_objects(files, obj_copies)


func _process(_delta):
	pass


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
				print(path + file)
		return files
	else:
		print("an error occurred while accessing the path:", path)


func pool_objects(files, num_copies):
	for file in files:
		var resource = load(file)
		for i in num_copies:
			var object: KinematicBody2D = resource.instance()
			object.global_position = Vector2(2000, 0)
			if (object.connect("off_screen", self, "place_tilemap") != OK):
				print("Error connecting signal from tilemap nodes")
			obj_pool.append(object)
			obj_available.append(object)
			get_parent().call_deferred('add_child_below_node', self, object)


#Called when signal is recieved from Ground_Tile.gd that a ground tile has gone off screen
func place_tilemap(): 
	rng.randomize()
	var index_select = rng.randi_range(0, len(obj_available)-1)
	var object = obj_available[index_select]
	object.global_position = Vector2(500, 150)
	#obj_available.remove(index_select)
	obj_in_scene.append(object)
	print("signal recieved")
