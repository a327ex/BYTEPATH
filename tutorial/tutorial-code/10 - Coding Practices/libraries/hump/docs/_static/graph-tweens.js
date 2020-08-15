(function() {
"use strict";

// DISCLAIMER: I just started learning d3, so this is certainly not good
//             idiomatic d3 code. But hey, it works (kinda).

var tweens = {
	'out': function(f) { return function(s) { return 1-f(1-s) } },
	'chain': function(f1, f2) { return function(s) { return ((s<.5) ? f1(2*s) : 1+f2(2*s-1)) * .5 } },
	'linear': function(s) { return s },
	'quad': function(s) { return s*s },
	'cubic': function(s) { return s*s*s },
	'quart': function(s) { return s*s*s*s },
	'quint': function(s) { return s*s*s*s*s },
	'sine': function(s) { return 1 - Math.cos(s*Math.PI/2) },
	'expo': function(s) { return Math.pow(2, 10*(s-1)) },
	'circ': function(s) { return 1 - Math.sqrt(Math.max(0,1-s*s)) },
	'back': function(s) { var b = 1.70158; return s*s*((b+1)*s - b) },
	'bounce': function(s) {
		return Math.min(
				7.5625 * Math.pow(s, 2),
				7.5625 * Math.pow((s - .545455), 2) + .75,
				7.5625 * Math.pow((s - .818182), 2) + .90375,
				7.5625 * Math.pow((s - .954546), 2) + .984375)
	},
	'elastic': function(s) {
		return -Math.sin(2/0.3 * Math.PI * (s-1) - Math.asin(1)) * Math.pow(2, 10*(s-1))
	},
};
var tweenfunc = tweens.linear;


var width_graph       = 320,
    width_anim_move   = 110,
    width_anim_rotate = 110,
    width_anim_size   = 110,
    height = 250;

// "UI"
var graph_ui = d3.select("#tween-graph").append("div")
	.attr("id", "tween-graph-ui");
// rest see below

// the graph
var graph = d3.select("#tween-graph").append("svg")
	.attr("width", width_graph).attr("height", height);

// background
graph.append("rect")
	.attr("width", "100%").attr("height", "100%")
	.attr("style", "fill:rgb(240,240,240);stroke-width:1;stroke:rgb(100,100,100);");

var y_zero = height * .78, y_one = height * .22;
graph.append("rect")
	.attr("y", y_one)
	.attr("width", "100%").attr("height", y_zero - y_one)
	.attr("style", "fill:steelblue;fill-opacity:.3;stroke-width:1;stroke:rgba(100,100,100,.7)");

// time arrow
graph.append("defs")
	.append("marker")
		.attr("id", "triangle")
		.attr("viewBox", "0 0 10 10")
		.attr("refX", 1).attr("refY", 5)
		.attr("markerWidth", 4)
		.attr("markerHeight", 4)
		.attr("orient", "auto")
		.attr("style", "fill:rgba(0,0,0,.5)")
		.append("path").attr("d", "M 0 0 L 10 5 L 0 10 z");

graph.append("line")
	.attr("x1", width_graph/2-80)
	.attr("x2", width_graph/2+80)
	.attr("y1", y_zero + 40).attr("y2", y_zero + 40)
	.attr("style", "stroke-width:2;stroke:rgba(0,0,0,.5)")
	.attr("marker-end", "url(#triangle)");

graph.append("text")
	.text("Time")
	.attr("x", width_graph/2).attr("y", y_zero + 55)
	.attr("style", "text-anchor:middle;fill:rgba(0,0,0,.5);font-size:15px");

// the actual graph
var curve = d3.svg.line()
	.x(function(x) { return x*width_graph; })
	.y(function(x) { return tweenfunc(x) * (y_one - y_zero) + y_zero; })

var graph_curve = graph.append("path").attr("d", curve(d3.range(0,1.05,.005)))
	.attr("style", "fill:none;stroke-width:2;stroke:seagreen;");

var graph_marker = graph.append("circle")
	.attr("r", 5)
	.attr("style", "stroke:goldenrod;fill:none;stroke-width:3");

// finally, a label
var graph_label = graph.append("text")
	.text("linear")
	.attr("x", width_graph/2).attr("y", 20)
	.attr("style", "text-anchor:middle;font-weight:bold;font-size:15px;");


// animation examples - moving ball
var anim_move = d3.select("#tween-graph").append("svg")
	.attr("width", width_anim_move).attr("height", height);

anim_move.append("rect")
	.attr("width", "100%").attr("height", "100%")
	.attr("style", "fill:rgb(240,240,240);stroke-width:1;stroke:rgb(100,100,100);");

anim_move.append("rect")
	.attr("width", 10).attr("height", (y_zero - y_one))
	.attr("x", width_anim_move/2-5).attr("y", y_one)
	.attr("style", "fill:black;opacity:.1");

var anim_move_ball = anim_move.append("circle")
	.attr("cx", width_anim_move/2).attr("cy", y_one)
	.attr("r", 17)
	.attr("style", "fill:steelblue;stroke:rgb(90,90,90);stroke-width:5;");

// animation examples - rotating square
var anim_rotate = d3.select("#tween-graph").append("svg")
	.attr("width", width_anim_size).attr("height", height);

anim_rotate.append("rect")
	.attr("width", "100%").attr("height", "100%")
	.attr("style", "fill:rgb(240,240,240);stroke-width:1;stroke:rgb(100,100,100);");

var w = width_anim_size/2;
var anim_rotate_square = anim_rotate.append("rect")
	.attr("x", -w/2).attr("y", -w/4)
	.attr("width", w).attr("height", w/2)
	.attr("style", "fill:steelblue;stroke:rgb(90,90,90);stroke-width:5;");

// animation examples - resizing ellipse
var anim_size = d3.select("#tween-graph").append("svg")
	.attr("width", width_anim_size).attr("height", height);

anim_size.append("rect")
	.attr("width", "100%").attr("height", "100%")
	.attr("style", "fill:rgb(240,240,240);stroke-width:1;stroke:rgb(100,100,100);");

anim_size.append("ellipse")
	.attr("cx", width_anim_size/2).attr("cy", height/2)
	.attr("rx", 40).attr("ry", 120)
	.attr("style", "fill:rgb(150,150,150);stroke:black;stroke-width:2;opacity:.1");

var anim_size_ellipse = anim_size.append("ellipse")
	.attr("cx", width_anim_size/2).attr("cy", height/2)
	.attr("rx", 40).attr("ry", 40)
	.attr("style", "fill:steelblue;stroke:rgb(90,90,90);stroke-width:5;");


// make it move!
var t = 0;
window.setInterval(function() {
	t = (t + .025 / 3);
	if (t > 1.3) { t = -.3; }
	var tt = Math.max(Math.min(t, 1), 0);

	var s = tweenfunc(tt)
	var yy = s * (y_one - y_zero) + y_zero;
	var translate = "translate("+(width_anim_size/2)+" "+(height/2)+")";
	var rotate = "rotate(" + (s * 360) + ")";

	graph_marker.attr("cx", tt*width_graph).attr("cy", yy);
	anim_move_ball.attr("cy", y_one + y_zero - yy);
	anim_rotate_square.attr("transform", translate + " " + rotate);
	anim_size_ellipse.attr("ry", s * 80 + 40);
}, 25);


// ui continued
graph_ui.append("strong").text("Function: ");
var select_modifier = graph_ui.append("select");
select_modifier.append("option").text("in");
select_modifier.append("option").text("out");
select_modifier.append("option").text("in-out");
select_modifier.append("option").text("out-in");
graph_ui.append("strong").text("-")

var select_func = graph_ui.append("select")
var funcs = [];
for (var k in tweens)
{
	if (k != "out" && k != "chain")
	{
		select_func.append("option").text(k);
		funcs.push(k);
	}
}

var change_tweenfunc = function()
{
	var fname = funcs[select_func.node().selectedIndex];
	var mod = select_modifier.node().selectedIndex;

	tweenfunc = tweens[fname];
	if (mod == 1) // out
		tweenfunc = tweens.out(tweenfunc);
	else if (mod == 2) // in-out
		tweenfunc = tweens.chain(tweenfunc, tweens.out(tweenfunc));
	else if (mod == 3) // out-in
		tweenfunc = tweens.chain(tweens.out(tweenfunc), tweenfunc);

	// update curve
	graph_curve.attr("d", curve(d3.range(0,1.05,.005)))

	// update label
	if (mod != 0)
		graph_label.text((['in','out','in-out','out-in'])[mod] + "-" + fname);
	else
		graph_label.text(fname);
}

select_func.on("change", change_tweenfunc);
select_modifier.on("change", change_tweenfunc);

})();
