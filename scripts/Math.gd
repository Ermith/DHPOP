class_name Math

static func smooth_damp(current: float, target: float, currentVelocity: float, smoothTime:float, deltaTime: float, maxSpeed: float = INF):
		smoothTime = max(0.0001, smoothTime);
		var omega: float = 2.0 / smoothTime;

		var x: float = omega * deltaTime;
		var exponent: float = 1.0 / (1.0 + x + 0.48 * x * x + 0.235 * x * x * x);
		var change: float = current - target;
		var originalTo: float = target;

		var maxChange: float = maxSpeed * smoothTime;
		change = clamp(change, -maxChange, maxChange);
		target = current - change;

		var temp: float = (currentVelocity + omega * change) * deltaTime;
		currentVelocity = (currentVelocity - omega * temp) * exponent;
		var output: float = target + (change + temp) * exponent;

		var b1 = originalTo - current > 0.0
		var b2 = output > originalTo
		if b1 == b2:
			output = originalTo;
			currentVelocity = (output - originalTo) / deltaTime;

		return [output, currentVelocity]

static func smooth_damp_vec(current: Vector3, target: Vector3, currentVlocity: Vector3, smoothTime: float, deltaTime: float, maxSpeed: Vector3 = Vector3.INF):
	var tmp
	tmp = smooth_damp(current.x, target.x, currentVlocity.x, smoothTime, deltaTime, maxSpeed.x)
	current.x = tmp[0]
	currentVlocity.x = tmp[1]
	
	tmp = smooth_damp(current.y, target.y, currentVlocity.y, smoothTime, deltaTime, maxSpeed.y)
	current.y = tmp[0]
	currentVlocity.y = tmp[1]
	
	tmp = smooth_damp(current.z, target.z, currentVlocity.z, smoothTime, deltaTime, maxSpeed.z)
	current.z = tmp[0]
	currentVlocity.z = tmp[1]
	
	return [current, currentVlocity]

# Called when the node enters the scene tree for the first time.
static func Hey():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	pass
