class_name Superfractal

var ifs = []
var tree

func random_walk_through_tree(result, current_tree=tree):
	# get ifs you need now
	return result

func calculate_fractal(start=point.new(), delay=10, points=10000):
	var result = []
	# check if system is empty
	if len(ifs) > 0:
		# delay
		## to begin in the attractor
		start = ifs[0].random_walk(start, delay) # the first ifs must do it
		# real points
		result = random_walk_through_tree(
				[start],
				tree
		)
	return result

# dictionaries

static func from_dict(array, tree):
	var superfractal = Superfractal.new()
	superfractal.systems = []
	superfractal.tree = tree
	for entry in array:
		superfractal.systems.append(IFS.from_dict(entry))
	return superfractal
