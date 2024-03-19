class_name IFS

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

# dictionaries

static func from_dict(array):
	var ifs = []
	for entry in array:
		ifs.append(Contraction.from_dict(entry))
	return ifs
