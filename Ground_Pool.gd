extends Node2D

export var dir_path = "res://Scenes/Ground_Parts/"

var obj_pool: Array = []
var obj_available: Array = []

var obj_copies = 1

func _ready():
	var files = files_in_directory(dir_path)
	pool_objects(files, obj_copies)


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
			var object: TileMap = resource.instance()
			object.global_position = Vector2(500, 150)
			obj_pool.append(object)
			obj_available.append(object)
			get_parent().call_deferred('add_child_below_node', self, object)
