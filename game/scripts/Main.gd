extends Node

export (PackedScene) var grass_scene
export (PackedScene) var house_scene
export (PackedScene) var tower_scene
export (PackedScene) var windmill_scene


var island_width := 5
var island_length := 5
var island_status := []

var buildings := []
var windmills := []
var towers := []

var power_type_active := 0
var powers_left := 0

var building_scenes := []


func _ready():
	randomize()
	new_game()
	yield(get_tree().create_timer(2), "timeout")
	$Needed/AudioStreamPlayer.play()


func new_game():
	island_status = []
	buildings = []
	windmills = []
	towers = []
	power_type_active = 0
	building_scenes = []
	make_island()
	spawn_terrain()
	spawn_buildings()
	spawn_defenses()


func game_over(win):
	if win:
		$Needed/UI.show_win()
	else:
		$Needed/UI.show_game_over()
	
	for building in building_scenes:
		building.delete(1, true)


func spawn_defenses():
	var number_less = randi() % 2
	
	for _number in range(buildings.size() - number_less):
		var defense_type = randi() % 2
		var spawn_location = get_random_location()
		buildings.append(spawn_location)
		var defense = 0
		
		match defense_type:
			0:
				defense = tower_scene.instance()
				towers.append(spawn_location)
			1:
				defense = windmill_scene.instance()
				windmills.append(spawn_location)
		
		add_child(defense)
		building_scenes.append(defense)
		var error = defense.connect("clicked", self, "_on_Building_clicked")
		if error != 0:
			print("Connect error: " + str(error))
		defense.translation = Vector3(spawn_location.x, island_status[spawn_location.x][spawn_location.y], spawn_location.y)
		defense.rotation_degrees = Vector3(0, randi() % 360, 0)


func spawn_buildings():
	var number_of_buildings = (randi() % 4) + 2
	update_powers_left(round(number_of_buildings * 2))
	
	for _number in range(number_of_buildings):
		var spawn_location = get_random_location()
		buildings.append(spawn_location)
		var house = house_scene.instance()
		add_child(house)
		building_scenes.append(house)
		var error = house.connect("clicked", self, "_on_Building_clicked")
		if error != 0:
			print("Connect error: " + str(error))
		house.translation = Vector3(spawn_location.x, island_status[spawn_location.x][spawn_location.y], spawn_location.y)
		house.rotation_degrees = Vector3(0, randi() % 360, 0)


func spawn_terrain():
	for width_index in range(island_width):
		for length_index in range(island_length):
			for height_index in range(island_status[width_index][length_index] + 1):
				var grass = grass_scene.instance()
				add_child(grass)
				grass.translation = Vector3(width_index, height_index, length_index)


func make_island():
	fill_with_empty()
	
	for width_index in range(island_width):
		var one_width = island_status[width_index]
		for length_index in range(island_length):
			if one_width[length_index] != 0:
				continue
			var height = randi() % 10
			
			match height:
				0, 1, 2, 3, 4, 5:
					height = 0
				6, 7, 8:
					height = 1
				9:
					height = 2
			
			one_width[length_index] = height
			check_height_and_fix(width_index, length_index, height)
	
	print(island_status)


func check_height_and_fix(width, length, height):
	if not check_height_is_good(width, length, height):
		fix_tile(width, length, height)


func fix_tile(width, length, height):
	var valid_directions = []
	if width != 0:
		valid_directions.append([-1, 0])
		
	if length != 0:
		valid_directions.append([0, -1])
		
	if width != island_width - 1:
		valid_directions.append([1, 0])
		
	if length != island_length - 1:
		valid_directions.append([0, 1])
		
	var direction = randi() % valid_directions.size()
	
	var chosen_coordinate_width = width + valid_directions[direction][0]
	var chosen_coordinate_length = length + valid_directions[direction][1]
	
	island_status[chosen_coordinate_width][chosen_coordinate_length] = height - 1
	
	check_height_and_fix(chosen_coordinate_width, chosen_coordinate_length, height - 1)


func check_height_is_good(width, length, height):
	var check_height = 0
	
	if width != 0:
		check_height = island_status[width - 1][length]
		if abs(check_height - height) <= 1 and height <= check_height:
			return true
		
	if length != 0:
		check_height = island_status[width][length - 1]
		if abs(check_height - height) <= 1 and height <= check_height:
			return true
		
	if width != island_width - 1:
		check_height = island_status[width + 1][length]
		if abs(check_height - height) <= 1 and height <= check_height:
			return true
		
	if length != island_length - 1:
		check_height = island_status[width][length + 1]
		if abs(check_height - height) <= 1 and height <= check_height:
			return true
	
	return false


func fill_with_empty():
	for _width_index in range(island_width):
		var one_width = []
		for _length_index in range(island_length):
			one_width.append(0)
		
		island_status.append(one_width)


func get_random_location():
	var location = Vector2.ZERO
	while true:
		location.x = randi() % island_width
		location.y = randi() % island_length
		
		if location in buildings:
			continue
		else:
			return location


func get_nearby_defenses(location):
	var windmill = false
	var tower = false
	
	for width_index in range(3):
		width_index += location.x - 1
		
		for length_index in range(3):
			length_index += location.z - 1
			
			if not windmill and Vector2(width_index, length_index) in windmills:
				windmill = true
			if not tower and Vector2(width_index, length_index) in towers:
				tower = true
	
	return [windmill, tower]


func houses_left():
	for location in buildings:
		if not (location in windmills or location in towers):
			return true
	return false


func destroy_building(building_node, location):
	var vec_location = Vector2(location.x, location.z)
	buildings.erase(vec_location)
	if vec_location in windmills:
		windmills.erase(vec_location)
	elif vec_location in towers:
		towers.erase(vec_location)
	#call destroy
	building_scenes.erase(building_node)
	building_node.delete(power_type_active, false)


func compute_building(building_node, location):
	var nearby_defs = get_nearby_defenses(location)
		
	if nearby_defs[0] and power_type_active == 2:
		#do nothing
		pass
	elif nearby_defs[1] and power_type_active == 3:
		#do nothing
		pass
	else:
		destroy_building(building_node, location)
		match power_type_active:
			1:
				update_powers_left(powers_left - 6)
			2, 3:
				update_powers_left(powers_left - 3)
		
		match building_node.type:
			"House":
				update_powers_left(powers_left + 2)
			"Windmill", "Tower":
				update_powers_left(powers_left + 2)
		
		if powers_left < 0:
			game_over(false)
		elif not houses_left():
			game_over(true)
		elif powers_left < 2:
			game_over(false)


func update_powers_left(new_power):
	powers_left = new_power
	$Needed/UI.set_power_label(powers_left)


func _on_Building_clicked(building_node, location):
	print(location)
	if power_type_active != 0:
		compute_building(building_node, location)


func _on_UI_enable_power(power_type):
	match power_type:
		"Fire":
			power_type_active = 1
		"Wind":
			power_type_active = 2
		"Lightning":
			power_type_active = 3
	
	print(power_type_active)


func _on_UI_restart():
	for scene in get_children():
		if scene.name != "Needed":
			scene.queue_free()
	new_game()

