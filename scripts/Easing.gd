extends Node3D
class_name Easing

static func reverse(f: Callable, t: float):
	return 1 - f.call(1 - t)
	
static func mix(a: Callable, b: Callable, t: float):
	var at = a.call(t)
	var bt = b.call(t)
	return lerp(at, bt, t)
	
static func smooth_start(t: float):
	return t * t;
	
static func smooth_end(t: float):
	return Easing.reverse(Easing.smooth_start, t);
	
static func smooth_step(t: float):
	return Easing.mix(Easing.smooth_start, Easing.smooth_end, t);

static func smooth_start3(t: float):
	return t*t*t;

static func smooth_end3(t: float):
	return Easing.reverse(Easing.smooth_start3, t)

static func smooth_step3(t:float):
	return Easing.mix(Easing.smooth_start3, Easing.smooth_end3, t)

static func linear(t: float):
	return t
