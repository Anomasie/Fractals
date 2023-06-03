class_name IFS

var systems = [] # array of contractions

func random_walk(pos, length=1, distribution=[]):
	if length > 0:
		pos = systems[ randi_range(0, len(systems)-1) ].apply(pos)
		return random_walk(
			pos,
			length - 1,
			distribution
		)
	else:
		return pos

func calculate_fractal(start=Vector2(0.5,0.5), delay=10, points=10000):
	var result = []
	# check if system is empty
	if len(systems) > 0:
		# delay
		## to begin in the attractor
		start = random_walk(start, delay)
		# real points
		result.append(start)
		for n in range(1, points+1):
			result.append( random_walk(
				result[n-1],
				1,
				[]
			) )
	return result
