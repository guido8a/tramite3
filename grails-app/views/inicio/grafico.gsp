<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <style type="text/css">

    body {
        margin: 0;
    }

    canvas {
        display: block;
        margin: 40px auto;
    }

    </style>

</head>

<body>

<canvas id="my-canvas1" width="100" height="500" style="float: left"></canvas>
<canvas id="my-canvas2" width="100" height="500" style="float: left"></canvas>
<canvas id="my-canvas3" width="100" height="500"></canvas>
<canvas id="my-canvas4" width="100" height="500"></canvas>

<div id="cuadro" width="20" height="20">xxxxxxxxxxxx</div>

<script type="text/javascript" charset="utf-8">

    var grid_size = 25;
    var x_axis_distance_grid_lines = 1;
    var y_axis_distance_grid_lines = 0;
    // var x_axis_starting_point = { number: 1, suffix: '\u03a0' };
    var x_axis_starting_point = { number: 1, suffix: 'u' };
    var y_axis_starting_point = { number: 1, suffix: '' };

    var cuadro = document.getElementById("cuadro");
    var canvas = document.getElementById("my-canvas1");
    var canvas2 = document.getElementById("my-canvas2");
    var ctx = canvas.getContext("2d");
    var ctx2 = canvas2.getContext("2d");

    var canvas_width = canvas.width;
    var canvas_height = canvas.height;

    var num_lines_x = Math.floor(canvas_height/grid_size);
    var num_lines_y = Math.floor(canvas_width/grid_size);

    // Draw grid lines along X-axis
    for(var i=0; i<=num_lines_x; i++) {
        ctx.beginPath();
        ctx.lineWidth = 1;

        // If line represents X-axis draw in different color
        if(i == x_axis_distance_grid_lines)
            ctx.strokeStyle = "#000000";
        else
            ctx.strokeStyle = "#e9e9e9";

        if(i == num_lines_x) {
            ctx.moveTo(0, grid_size*i);
            ctx.lineTo(canvas_width, grid_size*i);
        }
        else {
            ctx.moveTo(0, grid_size*i+0.5);
            ctx.lineTo(canvas_width, grid_size*i+0.5);
        }
        ctx.stroke();
    }

    // Draw grid lines along Y-axis
    for(i=0; i<=num_lines_y; i++) {
        ctx.beginPath();
        ctx.lineWidth = 1;

        // If line represents X-axis draw in different color
        if(i == y_axis_distance_grid_lines)
            ctx.strokeStyle = "#000000";
        else
            ctx.strokeStyle = "#e9e9e9";

        if(i == num_lines_y) {
            ctx.moveTo(grid_size*i, 0);
            ctx.lineTo(grid_size*i, canvas_height);
        }
        else {
            ctx.moveTo(grid_size*i+0.5, 0);
            ctx.lineTo(grid_size*i+0.5, canvas_height);
        }
        ctx.stroke();
    }

    // Translate to the new origin. Now Y-axis of the canvas is opposite to the Y-axis of the graph. So the y-coordinate of each element will be negative of the actual
    ctx.translate(y_axis_distance_grid_lines*grid_size, x_axis_distance_grid_lines*grid_size);

    // Ticks marks along the positive X-axis
    for(i=1; i<(num_lines_y - y_axis_distance_grid_lines); i++) {
        ctx.beginPath();
        ctx.lineWidth = 1;
        ctx.strokeStyle = "#000000";

        // Draw a tick mark 6px long (-3 to 3)
        ctx.moveTo(grid_size*i+0.5, -3);
        ctx.lineTo(grid_size*i+0.5, 3);
        ctx.stroke();

        // Text value at that point
        ctx.font = '9px Arial';
        ctx.textAlign = 'start';
        ctx.fillText(x_axis_starting_point.number*i + x_axis_starting_point.suffix, grid_size*i-2, -15);
    }

    // Ticks marks along the negative X-axis
    for(i=1; i<y_axis_distance_grid_lines; i++) {
        ctx.beginPath();
        ctx.lineWidth = 1;
        ctx.strokeStyle = "#000000";

        // Draw a tick mark 6px long (-3 to 3)
        ctx.moveTo(-grid_size*i+0.5, -3);
        ctx.lineTo(-grid_size*i+0.5, 3);
        ctx.stroke();

        // Text value at that point
        ctx.font = '9px Arial';
        ctx.textAlign = 'end';
        ctx.fillText(-x_axis_starting_point.number*i + x_axis_starting_point.suffix, -grid_size*i+3, 15);
    }

    // Ticks marks along the positive Y-axis
    // Positive Y-axis of graph is negative Y-axis of the canvas
    for(i=1; i<(num_lines_x - x_axis_distance_grid_lines); i++) {
        ctx.beginPath();
        ctx.lineWidth = 1;
        ctx.strokeStyle = "#000000";

        // Draw a tick mark 6px long (-3 to 3)
        ctx.moveTo(-3, grid_size*i+0.5);
        ctx.lineTo(3, grid_size*i+0.5);
        ctx.stroke();

        // Text value at that point
        ctx.font = '9px Arial';
        ctx.textAlign = 'start';
        ctx.fillText(-y_axis_starting_point.number*i + y_axis_starting_point.suffix, 8, grid_size*i+3);
    }

    // Ticks marks along the negative Y-axis
    // Negative Y-axis of graph is positive Y-axis of the canvas
    for(i=1; i<x_axis_distance_grid_lines; i++) {
        ctx.beginPath();
        ctx.lineWidth = 1;
        ctx.strokeStyle = "#000000";

        // Draw a tick mark 6px long (-3 to 3)
        ctx.moveTo(-3, -grid_size*i+0.5);
        ctx.lineTo(3, -grid_size*i+0.5);
        ctx.stroke();

        // Text value at that point
        ctx.font = '9px Arial';
        ctx.textAlign = 'start';
        ctx.fillText(y_axis_starting_point.number*i + y_axis_starting_point.suffix, 8, -grid_size*i+3);
    }

    // graficar lineas de un punto a otro
    ctx.beginPath();
    ctx.lineWidth = 0.5;
    ctx.strokeStyle = "#7aa3f0";
    ctx2.strokeStyle = "#ff8380";
    var px = 0;
    var py = 0;
    var inicio = true;
    // console.log('x', px, 'x_axis_distance_grid_lines', x_axis_distance_grid_lines);
    for(i=1; i<canvas_height; i++) {
        // Draw a tick mark 6px long (-3 to 3)
        px = Math.random()*(canvas_width);
        py++;
        // console.log('x', px, 'y', py);
        if(inicio) {
            ctx.moveTo(0, 0);
            ctx.lineTo(px, py);
            ctx.stroke();
            inicio = false;

            ctx2.moveTo(0, 0);
            ctx2.lineTo(px, py);
            ctx2.stroke();
            inicio = false;
        } else {
            ctx.lineTo(px, py);
            ctx.stroke();

            ctx2.lineTo(px, py);
            ctx2.stroke();
        }
    }

    ctx2 = ctx;

    function getMousePosition(canvas, event) {
        let rect = canvas.getBoundingClientRect();
        let x = event.clientX - rect.left;
        let y = event.clientY - rect.top;
        console.log("Coordinate x: " + x,
            "Coordinate y: " + y);
        draw(event, x, y);
    }

    let canvasElem = document.querySelector("canvas");

    canvasElem.addEventListener("mousedown", function(e)
    {
        getMousePosition(canvasElem, e);
    });


    function getMousePos(canvas, evt) {
        var rect = canvas.getBoundingClientRect();
        return {
            x: evt.clientX - rect.left,
            y: evt.clientY - rect.top
        };
    }

    // var canvas = document.getElementById("imgCanvas");
    // var ctx = canvas.getContext("2d");

    function draw(evt, x, y) {
        var pos = getMousePos(canvas, evt);
        cuadro.top = y;
        cuadro.left = x;
        cuadro.hidden = false;
        // ctx.fillStyle = "#000000";
        // ctx.fillRect (x, y, 14, 14);
    }

    function handleMouseDown(e){
        draw(e)
    }

</script>
</body>

</html>