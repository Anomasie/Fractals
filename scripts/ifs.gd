class_name IFS

const ACCURACY = 0.0000001

var systems = [] # array of contractions
var background_color = Color.WHITE
var delay = Global.DEFAULT_DELAY

func apply_contraction(pos):
	if len(systems) > 0:
		var distribution = get_distribution()
		var random = randf_range(0, distribution[-1])
		for i in len(distribution):
			if random <= distribution[i]:
				var result = point.new()
				result.position = systems[ i ].apply(pos.position)
				result.color = systems[ i ].mix(pos.color)
				return [result, i]
	else:
		return

func random_walk(pos, length=1, distribution=[]):
	if length > 0:
		if len(distribution) == 0:
			var fs = systems[ randi_range(0, len(systems)-1) ]
			var result = point.new()
			result.position = fs.apply(pos.position)
			result.color = fs.mix(pos.color)
			return random_walk(
				result,
				length - 1,
				distribution
			)
		else:
			var random = randf_range(0, distribution[-1])
			for i in len(distribution):
				if random <= distribution[i]:
					var result = point.new()
					result.position = systems[ i ].apply(pos.position)
					result.color = systems[ i ].mix(pos.color)
					return random_walk(
						result,
						length - 1,
						distribution
					)
	else:
		return pos

func calculate_fractal(start=point.new(), points=2000):
	var result = []
	# check if system is empty
	if len(systems) > 0:
		# delay
		## to begin in the attractor
		start = random_walk(start, delay)
		# real points
		result.append(start)
		var distribution = get_distribution()
		for n in range(1, points+1):
			result.append( random_walk(
				result[n-1],
				1,
				distribution
			) )
	return result

# where will the corners of the unit square be after steps_left steps?
func calculate_fractal_corners( corners = [Vector2(0,0), Vector2(1,0), Vector2(0,1), Vector2(1,1)], steps_left = 4 ):
	var result = []
	if steps_left > 0:
		for system in systems:
			for p in corners:
				p = system.apply(p)
			result += calculate_fractal_corners(
				corners,
				steps_left - 1
			)
	else:
		for system in systems:
			for p in corners:
				result.append(system.apply(p))
	return result

func get_distribution():
	var sum = 0.0
	var distribution = []
	for function in systems:
		sum += function.contract.x * function.contract.y
		distribution.append(sum)
	return distribution

# conversion of data types

func round_all(array):
	var new_array = []
	for element in array:
		new_array.append( snapped(element, ACCURACY) )
	return new_array

func to_meta_data():
	# version
	var string = "v1"
	# background color
	string += "|" + background_color.to_html()
	# delay
	string += "|" + str(delay)
	# ifs data
	for contraction in systems:
		string += "|"
		string += str(contraction.translation.x) + "," + str(contraction.translation.y) + ","
		string += str(contraction.contract.x) + "," + str(contraction.contract.y) + ","
		string += str(contraction.rotation) + ","
		string += str(int(contraction.mirrored)) + ","
		string += contraction.color.to_html(false)
	return string

static func from_meta_data(meta_data):
	if meta_data:
		# get version
		if meta_data[0] == "v":
			meta_data.trim_prefix("v")
			var version = int(meta_data.split("|", false)[0])
			return from_meta_data_version(meta_data, version)
		else:
			return from_meta_data_version(meta_data, 0)

static func from_meta_data_version(meta_data, version):
	match version:
		# WARNING: Don't change anything as long as you want to support old links!
		0:
			# split into units
			var units = meta_data.split("|", false)
			if len(units) > 0:
				var ifs = IFS.new()
				
				# background color
				ifs.background_color = Color.from_string(units[0], Color.WHITE)
				## background color saved? -> delete first entry
				if Color.html_is_valid(units[0]): 
					units.remove_at(0)
				
				# delay
				if len(units) > 0 and len(units[0].split(",", false)) == 1:
					ifs.delay = int(units[0])
					units.remove_at(0)
				
				# functions
				var meta_ifs_systems = []
				for i in len(units):
					var entries = units[i].split(",", false)
					if len(entries) < 6: # someone messed up the url! >:(
						return
					var contraction = Contraction.new()
					contraction.translation = Vector2(float(entries[0]), float(entries[1]))
					contraction.contract = Vector2(float(entries[2]), float(entries[3]))
					contraction.rotation = float(entries[4])
					contraction.mirrored = (entries[5] in ["1", "true"])
					if contraction.mirrored: # if mirrored: change anchor to bottom-left point
						contraction.translation += Vector2(contraction.contract.x, 0).rotated(-contraction.rotation)
					contraction.color = Color.from_string(entries[6], Color.BLACK) # black is default
					meta_ifs_systems.append(contraction)
				ifs.systems = meta_ifs_systems
				
				return ifs
		_: # current version
			# split into units:
			## very first is the version
			## first unit is the background color
			## second unit stands for delay
			## the rest are the systems to portray
			var units = meta_data.split("|", false)
			if len(units) > 0:
				var ifs = IFS.new()
				
				units.remove_at(0)
				
				# background color
				ifs.background_color = Color.from_string(units[0], Color.WHITE)
				units.remove_at(0)
				
				# delay
				ifs.delay = int(units[0])
				units.remove_at(0)
				
				# functions
				var meta_ifs_systems = []
				for i in len(units):
					var entries = units[i].split(",", false)
					if len(entries) < 6: # someone messed up the url! >:(
						return
					var contraction = Contraction.new()
					contraction.translation = Vector2(float(entries[0]), float(entries[1]))
					contraction.contract = Vector2(float(entries[2]), float(entries[3]))
					contraction.rotation = float(entries[4])
					contraction.mirrored = (entries[5] in ["1", "true"])
					contraction.color = Color.from_string(entries[6], Color.BLACK) # black is default
					meta_ifs_systems.append(contraction)
				ifs.systems = meta_ifs_systems
				
				return ifs

# dictionaries

func to_dict():
	var dict = {}
	dict["background color"] = background_color.to_html()
	dict["delay"] = delay
	dict["systems"] = []
	for contraction in systems:
		var matrix = round_all(contraction.to_matrix())
		dict["systems"].append(
			{
				"translation": [
					snapped(contraction.translation.x, ACCURACY),
					snapped(contraction.translation.y, ACCURACY)
				],
				"matrix": matrix,
				"color": contraction.color.to_html()
			}
		)
	return dict

static func from_dict(dict):
	var ifs = IFS.new()
	if dict.has("background color"):
		ifs.background_color = Color.from_string(dict["background color"], Color.WHITE)
	if dict.has("delay"):
		ifs.delay = int(dict["delay"])
	if dict.has("systems"):
		for system in dict["systems"]:
			var contraction = Contraction.new()
			# matrix
			if system.has("matrix") and typeof(system["matrix"]) == TYPE_ARRAY and len(system["matrix"]) == 4:
				contraction = contraction.from_matrix(system["matrix"])
			if system.has("translation") and typeof(system["translation"]) == TYPE_ARRAY and len(system["translation"]) == 2:
				contraction.translation = Vector2(
					float(system["translation"][0]),
					float(system["translation"][1])
				)
			if system.has("color"):
				contraction.color = Color.from_string(str(system["color"]), Color.BLACK)
			ifs.systems.append(contraction)
	return ifs
