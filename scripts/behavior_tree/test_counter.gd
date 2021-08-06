extends Task

class_name Counter

var count = 0

const MAX = 100

func run():
	if status == RUNNING:
		count += 1
	
	if count <= MAX:
	  print("%s counting: %d" % [name, count])
	  running()
	else:
	  print("Counter %s done!" % name)
	  count = 0
	  success() 
