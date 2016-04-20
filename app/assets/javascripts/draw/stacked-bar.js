var data;

var processData = function(info, callback) {
  var category = info.category,
      stack = info.stack,
      measure = info.measure,
      items = JSON.parse(JSON.stringify(data["items"])),
      categories = JSON.parse(JSON.stringify(data["values"][getDataHeaderKey(data, category)])),
      stacks = JSON.parse(JSON.stringify(data["values"][getDataHeaderKey(data, stack)])).reverse(),
      processedData = [];

  for (var j =  0; j < categories.length; j++) {
    var datum = {};

    if(categories[j] == null)
      categories[j] = "null" + j;

    datum[category] = categories[j];

    for (var k = 0; k < stacks.length; k++) {
      datum[stacks[k]] = 0;
    }
    processedData.push(datum);
  }
  var time = new Date().getTime();
  console.log("start")
  for (var i = items.length - 1; i >= 0; i--) {
    var indexCat = categories.indexOf(items[i][getDataHeaderKey(data, category)]),
        indexStack = stacks.indexOf(items[i][getDataHeaderKey(data, stack)]);

    if (indexCat >= 0 && indexStack >= 0){
      if (measure == 'count')
        processedData[indexCat][stacks[indexStack]]++;
      else
        processedData[indexCat][stacks[indexStack]] += JSON.parse(items[i][getDataHeaderKey(data, measure)].replace(/,/g, ''))
    }
  }
  console.log(new Date().getTime()-time)

  callback(processedData);
}

var drawStackedBars = function (data, info) {
  var category = info.category,
      stack = info.stack,
      measure = info.measure;

  var buildLegend = category != stack;

  var measurePad = 30,
      margin = {top: 20, right: 20, bottom: 30, left: 40},
      width = $(".visualization-container").width() - margin.left - margin.right,
      height = $(".visualization-container").height() - $("#sequence").height() - $(".title").height() - $(".caption").height() - 15 - margin.top - margin.bottom;

  var color_range = ['#ffffcc','#ffeda0','#fed976','#feb24c','#fd8d3c','#fc4e2a','#e31a1c','#bd0026','#800026'].reverse();

  if (!buildLegend)
    color_range = ['#800026']

  var color = d3.scale.ordinal()
      .range(color_range);


  var svg = d3.select("#chart").append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
    .append("g")
      .attr("transform", "translate(" + (margin.left+measurePad) + "," + margin.top + ")");

  width = width - measurePad;

  var x = d3.scale.ordinal()
      .rangeRoundBands([0, width], .1);

  var xAxis = d3.svg.axis()
      .scale(x)
      .orient("bottom");

  var active_link = "0"; //to control legend selections and hover
  var legendClicked; //to control legend selections
  var legendClassArray = []; //store legend classes to select bars in plotSingle()
  var y_orig; //to store original y-posn

  // d3.csv("catgory_data.csv", function(error, data) {
  //   if (error) throw error;

    color.domain(d3.keys(data[0]).filter(function(key) { return key !== category; }));

    data.forEach(function(d) {
      var myCat = d[category]; //add to stock code
      var y0 = 0;
      //d.ages = color.domain().map(function(name) { return {name: name, y0: y0, y1: y0 += +d[name]}; });
      d.ages = color.domain().map(function(name) { return {myCat:myCat, name: name, y0: y0, y1: y0 += +d[name]}; });
      d.total = d.ages[d.ages.length - 1].y1;

    });

    data.sort(function(a, b) { return b.total - a.total; });

    data = data.slice(0, 80);

    x.domain(data.map(function(d) { return d[category]; }));


    var gXAxis = svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height + ")")
        .call(xAxis);

    gXAxis.selectAll("text")
      .style("text-anchor", "end")
      .attr("dx", "-.8em")
      .attr("dy", ".15em")
      .attr("transform", "rotate(-65)");

    // Find the maxLabel height, adjust the height accordingly and transform the x axis.
    var xmaxWidth = 0;
    gXAxis.selectAll("text").each(function () {
      var boxWidth = this.getBBox().width;
      if (boxWidth > xmaxWidth) xmaxWidth = boxWidth;
    });

    height = height - xmaxWidth;

    gXAxis.attr("transform", "translate(0," + height + ")");

    var y = d3.scale.linear()
        .rangeRound([height, 0]);


    var yAxis = d3.svg.axis()
        .scale(y)
        .orient("left")
        .tickFormat(d3.format(".2s"));

    y.domain([0, d3.max(data, function(d) { return d.total; })]);

    var gYAxis = svg.append("g")
        .attr("class", "y axis")
        .call(yAxis);

    var catgory = svg.selectAll(".catgory")
        .data(data)
      .enter().append("g")
        .attr("class", "g")
        .attr("transform", function(d) { return "translate(" + "0" + ",0)"; });
        //.attr("transform", function(d) { return "translate(" + x(d[category]) + ",0)"; })

    catgory.selectAll("rect")
        .data(function(d) {
          return d.ages; 
        })
        .attr("height", function (d) { return height })
      .enter().append("rect")
        .attr("width", x.rangeBand())
        .attr("y", function(d) { return y(d.y1); })
        .attr("x",function(d) { //add to stock code
            return x(d.myCat)
          })
        .attr("height", function(d) { return y(d.y0) - y(d.y1); })
        .attr("class", function(d) {
          classLabel = d.name.replace(/\s/g, ''); //remove spaces
          return "class" + classLabel;
        })
        .style("fill", function(d) { return color(d.name); });

    catgory.selectAll("rect")
        .on("mouseover", function(d){

          var delta = d.y1 - d.y0;
          var xPos = parseFloat(d3.select(this).attr("x"));
          var yPos = parseFloat(d3.select(this).attr("y"));
          var width = parseFloat(d3.select(this).attr("width"));
          var height = parseFloat(d3.select(this).attr("height"));

          d3.select(this).attr("stroke","red").attr("stroke-width",0.8);

          svg.append("text")
          .attr("x",xPos +width/2)
          .attr("y",yPos +height/2)
          .attr("class","tooltip")
          .text(d.name +": "+ delta.toFixed(2)); 
          
        })
       .on("mouseout",function(){
          svg.select(".tooltip").remove();
          d3.select(this).attr("stroke","pink").attr("stroke-width",0.2);
        })

    var measureLabel = gYAxis.append("g")
          .attr("class", "visualization-labels")
          .attr("transform", "translate(" + -(margin.left+measurePad/2) + "," + (height/2-margin.top) + ")")
        .append("text")
          .style("text-anchor", "middle")
          .style("font-weight", "600")
          .attr("transform", "rotate(-90)")
          .text(measure);

    var categoryLabel = gXAxis.append("g")
          .attr("class", "visualization-labels")
          .attr("transform", "translate(" + width/2 + "," + (xmaxWidth+margin.top) + ")")
        .append("text")
          .style("text-anchor", "middle")
          .style("font-weight", "600")
          .text(category);

    if (buildLegend) {

      var stackLabel = svg.append("g")
            .attr("class", "visualization-labels")
            .attr("transform", "translate(" + width + "," + 13 + ")")
          .append("text")
            .style("text-anchor", "end")
            .style("font-weight", "600")
            .text(stack);

      var legend = svg.selectAll(".legend")
          .data(color.domain().slice().reverse())
        .enter().append("g")
          //.attr("class", "legend")
          .attr("class", function (d) {
            legendClassArray.push(d.replace(/\s/g, '')); //remove spaces
            return "legend";
          })
          .attr("transform", function(d, i) { return "translate(0," + (i * 20 + 20) + ")"; });

      //reverse order to match order in which bars are stacked    
      legendClassArray = legendClassArray.reverse();

      legend.append("rect")
          .attr("x", width - 18)
          .attr("width", 18)
          .attr("height", 18)
          .style("fill", color)
          .attr("id", function (d, i) {
            return "id" + d.replace(/\s/g, '');
          })
          .on("mouseover",function(){        

            if (active_link === "0") d3.select(this).style("cursor", "pointer");
            else {
              if (active_link.split("class").pop() === this.id.split("id").pop()) {
                d3.select(this).style("cursor", "pointer");
              } else d3.select(this).style("cursor", "auto");
            }
          })
          .on("click",function(d){         

            if (active_link === "0") { //nothing selected, turn on this selection
              d3.select(this)           
                .style("stroke", "black")
                .style("stroke-width", 2);

                active_link = this.id.split("id").pop();
                plotSingle(this);

                //gray out the others
                for (i = 0; i < legendClassArray.length; i++) {
                  if (legendClassArray[i] != active_link) {
                    d3.select("#id" + legendClassArray[i])
                      .style("opacity", 0.5);
                  }
                }
               
            } else { //deactivate
              if (active_link === this.id.split("id").pop()) {//active square selected; turn it OFF
                d3.select(this)           
                  .style("stroke", "none");

                active_link = "0"; //reset

                //restore remaining boxes to normal opacity
                for (i = 0; i < legendClassArray.length; i++) {              
                    d3.select("#id" + legendClassArray[i])
                      .style("opacity", 1);
                }

                //restore plot to original
                restorePlot(d);

              }

            } //end active_link check

          });

      legend.append("text")
          .attr("x", width - 24)
          .attr("y", 9)
          .attr("dy", ".35em")
          .style("text-anchor", "end")
          .text(function(d) { return d; });

      function restorePlot(d) {

        catgory.selectAll("rect").forEach(function (d, i) {      
          //restore shifted bars to original posn
          d3.select(d[idx])
            .transition()
            .duration(500)        
            .attr("y", y_orig[i]);
        })

        //restore opacity of erased bars
        for (i = 0; i < legendClassArray.length; i++) {
          if (legendClassArray[i] != class_keep) {
            d3.selectAll(".class" + legendClassArray[i])
              .transition()
              .duration(500)
              .delay(250)
              .style("opacity", 1);
          }
        }

      }

      function plotSingle(d) {
            
        class_keep = d.id.split("id").pop();
        idx = legendClassArray.indexOf(class_keep);    
       
        //erase all but selected bars by setting opacity to 0
        for (i = 0; i < legendClassArray.length; i++) {
          if (legendClassArray[i] != class_keep) {
            d3.selectAll(".class" + legendClassArray[i])
              .transition()
              .duration(500)          
              .style("opacity", 0);
          }
        }

        //lower the bars to start on x-axis
        y_orig = [];
        catgory.selectAll("rect").forEach(function (d, i) {        
        
          //get height and y posn of base bar and selected bar
          h_keep = d3.select(d[idx]).attr("height");
          y_keep = d3.select(d[idx]).attr("y");
          //store y_base in array to restore plot
          y_orig.push(y_keep);

          h_base = d3.select(d[0]).attr("height");
          y_base = d3.select(d[0]).attr("y");    

          h_shift = h_keep - h_base;
          y_new = y_base - h_shift;

          //reposition selected bars
          d3.select(d[idx])
            .transition()
            .ease("bounce")
            .duration(1000)
            .delay(250)
            .attr("y", y_new);
       
        })    
       
      } 

    }

  // });
}

// var visualize = function(res, selections, callback) {
//   data = res;
//   processData(selections, function(processedData){
//     drawStackedBars(processedData, selections);
//     callback;
//   });
// }

var visualize = function(processedData, selections) {
  drawStackedBars(processedData, selections);
}