class_name IFS

var systems = [] # array of contractions

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

func calculate_fractal(start=point.new(), delay=10, points=10000):
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

func get_distribution():
	var sum = 0.0
	var distribution = []
	for function in systems:
		sum += function.contract.x * function.contract.y
		distribution.append(sum)
	return distribution
