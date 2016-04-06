var data;

var linkNodes = function(graph, data, measure) {
  var items = JSON.parse(JSON.stringify(data["items"]))
  var loop = graph.nodes.length;
  var links = [];

  for (var i = 0; i < loop; i++) {
    for (var j = 0; j < loop; j++) {
      var link = {"source":i,"target":j,"value":0};
      links.push(link);
    }
  }
  var time = new Date().getTime()
  console.log("start")
  for (var i = items.length - 1; i >= 0; i--) {
    var item = items[i];

    for (var j = 0; j < loop; j++) {
      var ff = graph.nodes[j];
      if(item[ff.header] == ff.name){
        for (var k = j; k < loop; k++) {
          var tt = graph.nodes[k];
          if(ff.header == tt.header) continue;
          if(item[ff.header] == ff.name && item[tt.header] == tt.name){
            if (measure != 'count'){
              console.log(measure)
              links[j*loop+k].value += parseInt(item[measure].replace(/,/g, ''));
            }
            else links[j*loop+k].value++;
            delete item[ff.header]
          }
        }
      }
    }
  }
  console.log(new Date().getTime() - time)

  for (var i = links.length - 1; i >= 0; i--) {
    if (links[i].value == 0) {
      links.splice(i, 1);
    }
  }

  linkNodesWithOther(5, graph, data);
  graph.links = links;
}

var linkNodesWithOther = function(percent, graph, data) {
  var total = JSON.parse(JSON.stringify(data["count"])),
      limit = (percent/100*total) + 1;
  console.log(limit);
}

var drawSankey = function(graph) {
  var units = "";

  var margin = {top: 10, right: 10, bottom: 10, left: 10},
      width = $(".container").width() - margin.left - margin.right,
      height = $(".container").height() - $("#sequence").height() - $(".title").height() - $(".caption").height() - 30 - margin.top - margin.bottom;

  var formatNumber = d3.format(",.0f"),    // zero decimal places
      format = function(d) { return formatNumber(d) + " " + units; },
      color = d3.scale.category20();

  // append the svg canvas to the page
  var svg = d3.select("#chart").append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
    .append("g")
      .attr("transform", 
            "translate(" + margin.left + "," + margin.top + ")");

  // Set the sankey diagram properties
  var sankey = d3.sankey()
      .nodeWidth(36)
      .nodePadding(40)
      .size([width, height]);

  var path = sankey.link();

  // load the data
  // d3.json(data, function(error, graph) {

    sankey
        .nodes(graph.nodes)
        .links(graph.links)
        .layout(32);

  // add in the links
    var link = svg.append("g").selectAll(".link")
        .data(graph.links)
      .enter().append("path")
        .attr("class", "link")
        .attr("d", path)
        .style("stroke-width", function(d) { return Math.max(1, d.dy); })
        .sort(function(a, b) { return b.dy - a.dy; });

  // add the link titles
    link.append("title")
          .text(function(d) {
          return d.source.name + " → " + 
                  d.target.name + "\n" + format(d.value); });

  // add in the nodes
    var node = svg.append("g").selectAll(".node")
        .data(graph.nodes)
      .enter().append("g")
        .attr("class", "node")
        .attr("transform", function(d) { 
        return "translate(" + d.x + "," + d.y + ")"; })
      .call(d3.behavior.drag()
        .origin(function(d) { return d; })
        .on("dragstart", function() { 
        this.parentNode.appendChild(this); })
        .on("drag", dragmove));

  // add the rectangles for the nodes
    node.append("rect")
        .attr("height", function(d) { return d.dy; })
        .attr("width", sankey.nodeWidth())
        .style("fill", function(d) { 
        return d.color = color(d.name.replace(/ .*/, "")); })
        .style("stroke", function(d) { 
        return d3.rgb(d.color).darker(2); })
      .append("title")
        .text(function(d) { 
        return d.name + "\n" + format(d.value); });

  // add in the title for the nodes
    node.append("text")
        .attr("x", -6)
        .attr("y", function(d) { return d.dy / 2; })
        .attr("dy", ".35em")
        .attr("text-anchor", "end")
        .attr("transform", null)
        .text(function(d) { return d.name; })
      .filter(function(d) { return d.x < width / 2; })
        .attr("x", 6 + sankey.nodeWidth())
        .attr("text-anchor", "start");

  // the function for moving the nodes
    function dragmove(d) {
      d3.select(this).attr("transform", 
          "translate(" + d.x + "," + (
                  d.y = Math.max(0, Math.min(height - d.dy, d3.event.y))
              ) + ")");
      sankey.relayout();
      link.attr("d", path);
    }
  // });
}

var visualize = function(res, selections) {
  data = res;
  drawSankey(selections);
}