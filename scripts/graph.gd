class_name Graph

var ifs
var Children = []

func random_walk(result):
	var returned_value = ifs.apply_contraction(result[-1])
	if len(Children) > returned_value[1]:
		return Children[returned_value[1]].random_walk(result)
	else:
		result.append(returned_value[0])
		return result

func calculate_fractal(start=point.new(), delay=10, points=10000):
	var result = []
	# check if system is empty
	if len(ifs) > 0:
		# delay
		## to begin in the attractor
		var depth = get_depth()
		start = ifs.random_walk(start, int(delay / depth + 1) * depth) # the first ifs must do it
		result.append(start)
		# real points
		for _i in int(points / depth + 1) * depth:
			result = random_walk( result )
	return result

func get_depth():
	if len(Children) > 0:
		return Children[0].get_depth() + 1
	else:
		return 1

func get_graph_from_fiber(fiber):
	if len(fiber) > 1:
		var vertex = Graph.new()
		vertex.ifs = fiber[0]
		var amount = len(fiber[0].systems)
		fiber.pop_front()
		for _i in amount:
			vertex.Children.append(
				vertex.get_graph_from_fiber(
					fiber
				)
			)
		return vertex
	else:
		var last_vertex = Graph.new()
		last_vertex.ifs = fiber[0]
		return last_vertex
