var data;

var processData = function(levels, measure, callback) {
  var items = JSON.parse(JSON.stringify(data["items"]));
  var processedData = {name: "All", children: []};

  var time = new Date().getTime();

  $.each(items, function(key, item) {
    var node = {name: null, children: [], size: 0};
    var i = 0, max_i = levels.length;

    var f = function(parent_node, current_node, i) {
      if(i == max_i) return;
      var existing = parent_node.children[findWithAttr(parent_node.children, "name", item[getDataHeaderKey(data, levels[i])])]


      if (existing != undefined) {

        if (measure == 'count')
          existing.size++;
        else
          existing.size += JSON.parse(item[getDataHeaderKey(data, measure)].replace(/,/g, ''));

        current_node = existing;

        f(current_node, {name: null, children: [], size: 0}, ++i);
        return
      }
      else {
        current_node.name = item[getDataHeaderKey(data, levels[i])];
      }

      f(current_node, {name: null, children: [], size: 0}, ++i);

      if (current_node.children.length < 1){
        delete current_node.children;

        if (measure == 'count')
          current_node.size++;
        else
          current_node.size += JSON.parse(current_node.size)+JSON.parse(item[getDataHeaderKey(data, measure)].replace(/,/g, ''));
      }

      if (current_node.size < 1)
        delete current_node.size;

      parent_node.children.push(current_node);
    }
    f(processedData, node, i)
  })

  console.log(new Date().getTime()-time)

  callback(processedData);
}

// taken from http://stackoverflow.com/a/7178381
function findWithAttr(array, attr, value) {
  for(var i = 0; i < array.length; i += 1) {
      if(array[i][attr] === value) {
          return i;
      }
  }
}

function drawZoomable(root) {
  var width = $(".visualization-container").width() - 30,
      height = $(".visualization-container").height() - $("#sequence").height() - $(".title").height() - $(".caption").height() - 75,
      radius = (Math.min(width, height) / 2);

  var formatNumber = d3.format(",d");

  var x = d3.scale.linear()
      .range([0, 2 * Math.PI]);

  var y = d3.scale.sqrt()
      .range([0, radius]);

  var color = d3.scale.category20c();

  var partition = d3.layout.partition()
      .value(function(d) { return d.size; });

  var arc = d3.svg.arc()
      .startAngle(function(d) { return Math.max(0, Math.min(2 * Math.PI, x(d.x))); })
      .endAngle(function(d) { return Math.max(0, Math.min(2 * Math.PI, x(d.x + d.dx))); })
      .innerRadius(function(d) { return Math.max(0, y(d.y)); })
      .outerRadius(function(d) { return Math.max(0, y(d.y + d.dy)); });

  var svg = d3.select("#chart").append("svg")
      .attr("width", width)
      .attr("height", height)
    .append("g")
      .attr("id", "container")
      .attr("transform", "translate(" + width / 2 + "," + (height / 2) + ")");

  // d3.json("/mbostock/raw/4063550/flare.json", function(error, root) {
  //   if (error) throw error;

  var nodes = partition.nodes(root)
    .filter(function(d) {
      // console.log(d.dx)
      return (d.dx > 0.0007); // 0.005 radians = 0.29 degrees
    });

  var path = svg.selectAll("path")
      .data(nodes)
    .enter().append("path")
      .attr("d", arc)
      .style("fill", function(d) { return color(d.name); })
      .on("click", click)
      .on("mouseover", mouseover)
    .append("title")
      .text(function(d) { return d.name + "\n" + formatNumber(d.value); });
  // });

  function click(d) {
    svg.transition()
        .duration(750)
        .tween("scale", function() {
          var xd = d3.interpolate(x.domain(), [d.x, d.x + d.dx]),
              yd = d3.interpolate(y.domain(), [d.y, 1]),
              yr = d3.interpolate(y.range(), [d.y ? 20 : 0, radius]);
          return function(t) { x.domain(xd(t)); y.domain(yd(t)).range(yr(t)); };
        })
      .selectAll("path")
        .attrTween("d", function(d) { return function() { return arc(d); }; });
  }

  // Total size of all segments; we set this later, after loading the data.
  var totalSize = 0; 

  // Basic setup of page elements.
  initializeBreadcrumbTrail();

  // Add the mouseleave handler to the bounding circle.
  d3.select("#container").on("mouseleave", mouseleave);

  // Get total size of the tree = value of root node from partition.
  totalSize = path.node().__data__.value;

  // Fade all initializeBreadcrumbTrail the current sequence, and show it in the breadcrumb trail.
  function mouseover(d) {

    var percentage = (100 * d.value / totalSize).toPrecision(3);
    var percentageString = percentage + "%";
    if (percentage < 0.1) {
      percentageString = "< 0.1%";
    }

    d3.select("#percentage")
        .text(percentageString);

    d3.select("#explanation")
        .style("visibility", "");

    var sequenceArray = getAncestors(d);
    updateBreadcrumbs(sequenceArray, percentageString);

    // Fade all the segments.
    d3.selectAll("path")
        .style("opacity", 0.3);

    // Then highlight only those that are an ancestor of the current segment.
    svg.selectAll("path")
        .filter(function(node) {
                  return (sequenceArray.indexOf(node) >= 0);
                })
        .style("opacity", 1);
  }

  // Restore everything to full opacity when moving off the visualization.
  function mouseleave(d) {

    // Hide the breadcrumb trail
    d3.select("#trail")
        .style("visibility", "hidden");

    // Deactivate all segments during transition.
    d3.selectAll("path").on("mouseover", null);

    // Transition each segment to full opacity and then reactivate it.
    d3.selectAll("path")
        .transition()
        .duration(500)
        .style("opacity", 1)
        .each("end", function() {
                d3.select(this).on("mouseover", mouseover);
              });

    d3.select("#explanation")
        .style("visibility", "hidden");
  }

  // Given a node in a partition layout, return an array of all of its ancestor
  // nodes, highest first, but excluding the root.
  function getAncestors(node) {
    var path = [];
    var current = node;
    while (current.parent) {
      path.unshift(current);
      current = current.parent;
    }
    return path;
  }

  function initializeBreadcrumbTrail() {
    // Add the svg area.
    var trail = d3.select("#sequence").append("svg:svg")
        .attr("width", width)
        .attr("height", 50)
        .attr("id", "trail");
    // Add the label at the end, for the percentage.
    trail.append("svg:text")
      .attr("id", "endlabel")
      .style("fill", "#000");

    d3.selectAll("path").each(function(d) {
      var text = svg.append("text")
        .attr("text-anchor", "middle")
        .text(d.name);
      d.width = text.node().getBBox().width + 50;
      text.remove();
    })
  }

  // Breadcrumb dimensions: margin, height, spacing, width of tip/tail.
  var b = {
    m: 15, h: 30, s: 3, t: 10
  };

  function getTextWidth(text) {
    var a = document.createElement('canvas');
    var b = a.getContext('2d');
    return b.measureText(text).width;
  }

  // Generate a string that describes the points of a breadcrumb polygon.
  function breadcrumbPoints(d, i) {
    var points = [];
    points.push("0,0");
    points.push(d.width + ",0");
    points.push(d.width + b.t + "," + (b.h / 2));
    points.push(d.width + "," + b.h);
    points.push("0," + b.h);
    if (i > 0) { // Leftmost breadcrumb; don't include 6th vertex.
      points.push(b.t + "," + (b.h / 2));
    }
    
    return points.join(" ");
  }

  // Update the breadcrumb trail to show the current sequence and percentage.
  function updateBreadcrumbs(nodeArray, percentageString) {
    var offset = 0;

    // Data join; key function combines name and depth (= position in sequence).
    var g = d3.select("#trail")
        .selectAll("g")
        .data(nodeArray, function(d) { return d.name + d.depth; });

    // Add breadcrumb and label for entering nodes.
    var entering = g.enter().append("svg:g");

    entering.append("svg:polygon")
        .attr("points", breadcrumbPoints)
        .style("fill", function(d) { return color(d.name); });

    entering.append("svg:text")
        .attr("x", function(d) { return (d.width + b.t) / 2})
        .attr("y", b.h / 2)
        .attr("dy", "0.35em")
        .attr("text-anchor", "middle")
        .text(function(d) { return d.name; });

    // Set position for entering and updating nodes.
    g.each(function(d) {
      d.offset = offset;
      offset += d.width + 3;
    })

    g.attr("transform", function(d) {
      return "translate(" + (d.offset + b.s) + ", 0)";
    });

    // Remove exiting nodes.
    g.exit().remove();

    // Now move and update the percentage at the end.
    d3.select("#trail").select("#endlabel")
        .attr("x", offset + b.m)
        .attr("y", b.h / 2)
        .attr("dy", "0.35em")
        .attr("text-anchor", "start")
        .text(percentageString);

    // Make the breadcrumb trail visible, if it's hidden.
    d3.select("#trail")
        .style("visibility", "");

  }
}

var visualize = function(res, selections) {
  data = res;
  processData(selections.data, selections.measure, function(processedData){
    drawZoomable(processedData);
  });
}