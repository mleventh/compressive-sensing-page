        # Blank page
$("#"+id).empty() for id in ["func2", "alias_graph2", "l2_bar"]
 
# Helper function
abs = (z) -> (Math.abs(z[k]) for k in [0...z.length])
 
# Page
m = [20, 20, 20, 80] # margins
width = 400 - m[1] - m[3]
height = 300 - m[0] - m[2]
    
# Alias figure
N = 27  # number of points to evaluate
tmin = -5
tmax = 5
colors = ["red", "blue", "green", "purple"] # 1, t, t^2, t^3
 
# Alias cubic f(t)
f_coeff2 = (k, l) -> [k, 17/4-4*l, -1/8-k/4, l]
f2 = (t, k, l) -> z = f_coeff2(k, l).dot([1, t, t*t, t*t*t])
 
# Function text
f_text2 = (k, l) ->
    p = f_coeff2(k, l)
    a = (n) -> Math.round(100*p[n])/100
    b = (n) -> Math.round(100*p[n])/100
    s = (n) -> "<span style='color: #{colors[n]}'>#{a(n)}</span>"
    tr = (td1, td2) -> "<tr><td style='text-align:right;'>#{td1}</td><td>#{td2}</td><tr/>"
    """
    <table class='func2'>
    #{tr "f(t) = ", s(0)}
    #{tr "+", s(1)+"t"}
    #{tr "+", s(2)+"t<sup>2</sup>"}
    #{tr "+", s(3)+"t<sup>3</sup>"}

    </table>
    """

Bar = (k, l) ->
    @margin = top: 20, right: 30, bottom: 20, left: 50
    @width = 120 - @margin.left - @margin.right
    @height = 300 - @margin.top - @margin.bottom
    @stack = d3.layout.stack().values((d) -> d.values)
    @compute = (k, l) -> 
        b = (n, k, l) ->
            key: "Key_"+n,
            values: [{"x": 0, "y": abs(f_coeff2(k, l))[n]}]
        @data = [b(3, k, l), b(2, k, l), b(1, k, l), b(0, k, l)]
        @keys = @data[0].values.map((item) -> item.x )
        @layers = @stack(@data)
    @compute(k, l)
    this
 
Alias = (k, l) ->         
 
    # Scale f & t to screen
    t_to_px = d3.scale.linear().domain([tmin, tmax]).range([0, width])
    f_to_px = d3.scale.linear().domain([-20,20]).range([height, 0])
    n_to_t = d3.scale.linear().domain([0, N]).range([tmin, tmax])
    
    # Axes: horizontal (t); vertical (f)
    t_axis = d3.svg.axis()
        .scale(t_to_px)
        .ticks(6)
    f_axis = d3.svg.axis()
        .scale(f_to_px)
        .orient("left")
        .ticks(6)
 
    # N (t,f) points
    @f_data2 = (k, l) -> [0...N].map((d) -> {tn: n_to_t(d), fn: f2(n_to_t(d), k, l)})
    fdata2 = @f_data2(k, l)
 
    # (t,f) points to SVG    
    @f_svg = d3.svg.line()
        .x((d) -> t_to_px(d.tn))
        .y((d) -> f_to_px(d.fn))
 
    # Fixed samples
    f0 = [t_to_px(-2), f_to_px(f2(-2, k, l))]
    f1 = [t_to_px(2), f_to_px(f2(2, k, l))]
    samples = [f0, f1]
   
 
    # SVG
    
    @graph = d3.select("#alias_graph2")
        .append("svg")  
        .attr("width", width + m[1] + m[3])
        .attr("height", height + m[0] + m[2])
        .append("g")
        .attr("transform", "translate(" + m[3] + "," + m[0] + ")")
 
    @graph.append("g")
        .attr("class", "axis")
        .attr("transform", "translate(0," + height + ")")
        .call(t_axis)
        
    @graph.append("g")
        .attr("class", "axis")
        .attr("transform", "translate(-25,0)")
        .call(f_axis)

    #console.log "fdata", fdata, @f_svg(fdata)
    @graph.append("path")
        .attr("d", @f_svg(fdata2))
        .attr("id","poly")
 
    @graph.selectAll("circle")
        .data(samples)
        .enter()
        .append("circle")
        .attr("cx", (d) -> d[0])
        .attr("cy", (d) -> d[1])
        .attr("r", 5)
 
    # Slider2
    @compute = (k, l) ->
        fdata2 = @f_data2(k, l)
        @graph.select("#poly")
            .transition()
            .attr("d", @f_svg(fdata2))
    this
 
    # Slider3
    @compute = (k, l) ->
        fdata2 = @f_data2(k, l)
        @graph.select("#poly")
            .transition()
            .attr("d", @f_svg(fdata2))
    this
 
L2Bar = (bar) ->
 
    @svg = d3.select("#l2_bar").append("svg")
        .attr("width", bar.width + bar.margin.left + bar.margin.right)
        .attr("height", bar.height + bar.margin.top + bar.margin.bottom)
        .append("g")
        .attr("transform", 
            "translate(" + bar.margin.left + "," + bar.margin.top + ")")
 
    @layer = @svg.selectAll(".layer")
        .data(bar.layers)
        .enter()
        .append("g")
        .attr("class", "layer")
        .style("fill", (d, i) -> colors[3-i])
 
    @x = d3.scale.ordinal()
        .domain(bar.keys)
        .rangeRoundBands([0, bar.width], 0.08)
        
    @y = d3.scale.linear()
        .domain([0, 18])
        .range([bar.height, 0])
        
    x = @x
    y = @y
    
 
    @layer.selectAll("rect")
        .data((d) -> d.values)
        .enter()
        .append("rect")
        .attr("fill-opacity", 0.5)
        .attr("stroke", "#000")
        .attr("width", x.rangeBand())
        .attr("x", (d) -> d.x)
        .attr("y", (d) -> y(d.y0 + d.y))
        .attr("height", (d) -> y(d.y0) - y(d.y0 + d.y))


    t_axis = d3.svg.axis()
        .scale(x)
        .tickSize(0)
        .tickPadding(6)
        .orient("bottom")
 
    f_axis = d3.svg.axis()
        .scale(y)
        .ticks(6)
        .tickSize(0)
        .tickPadding(6)
        .orient("left")
 
    @svg.append("g")
        .attr("class", "axis")
        .call(f_axis)
            
    @compute = ->
        @layer = @svg.selectAll(".layer").data(bar.layers)
        y = @y
        @layer.selectAll("rect")
            .data((d) -> d.values)
            .attr("y", (d) -> y(d.y0 + d.y))
            .attr("height", (d) -> y(d.y0) - y(d.y0 + d.y))
    this
 
k = 1
l = 1
bar = new Bar(k, l)
alias = new Alias(k, l)
l2Bar = new L2Bar(bar)
d3.select("#func2").html(f_text2(k, l))
 
computeAll = (k, l) ->
    alias.compute(k, l)
    bar.compute(k, l)
    l2Bar.compute()
    d3.select("#func2").html(f_text2(k, l))
 
$("#slider2").on "change", -> 
    k = parseFloat(d3.select("#slider2").property("value"))
    l = parseFloat(d3.select("#slider3").property("value"))
    computeAll(k, l)
    $("#slider2").val(k, l)
 
d3.selectAll("#sparse1").on "click", -> 
    k = 1
    l = 1
    computeAll(k, l)
    $("#slider").focus()
    
$("#slider3").on "change", -> 
    k = parseFloat(d3.select("#slider2").property("value"))
    l = parseFloat(d3.select("#slider3").property("value"))
    computeAll(k, l)

d3.selectAll("#sparse1").on "click", -> 
    k = 1
    l = 1
    computeAll(k, l)
    $("#slider3").val(k, l)
    $("#slider3").focus()