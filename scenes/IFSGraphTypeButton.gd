extends TextureButton

var type = 0
# there are three basic types
# type 0 is a subclass of type 1 and type 1 is a subclass of type 2
# they are almost surely different

# type 0:
## a -> b -> c

# type 1:
## O
## |
## O
### all children have the same ifs

# type 2:
## 0 - 0
## all vertices are independent of each other


func get_current_graph():
	var type = RandomButton.type
	var graph = Graph.new()
	match type:
		0:
			
