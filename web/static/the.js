var Sunburst = function (sunburst){
  // Total size of all segments; we set this later, after loading the data.
  var totalSize = 0; 
  var total = 0;

  // Hold on to everything
  var tree = {};
  var list = [];
  var active, activated;

  // I get lazy
  var $     = function(el,selector){
    return (el || sunburst.el).querySelector(selector);
  }
  var set   = function(el, attr, value){
    el.setAttributeNS(null, attr, value);
  }
  var scope = function(node,callback){
    return function(){callback(node)}
  }

  // Let's do some scraping
  var trail       = $(null,".trail");
  var g           = $(null,".g");
  var percentage  = $(null,".percentage");
  var explanation = $(null,".explanation");
  var data        = $(null,".data");
  var modal       = $(null,".modal");
  var message     = $(null,".message");
  var progress    = $(null,".progress");
  var left        = $(null,".left");
  var right       = $(null,".right");

  // From settings
  var title = sunburst.title || data.textContent,
      raw   = sunburst.raw   || "quotes";

  // Some dom to render
  var svg  = 'http://www.w3.org/2000/svg';
  var path = document.createElementNS(svg,'path');
  set(path, "stroke", "none");

  // Prebuild a breadcrumb
  var group   = document.createElementNS(svg,'g'),
      text    = document.createElementNS(svg,'text'),
      polygon = document.createElementNS(svg,'polygon');

  set(text, "x", "15");
  set(text, "y", "20");
  set(text, "text-anchor", "left");
  group.appendChild(polygon);
  group.appendChild(text);

  // Dimensions of sunburst.
  var width, height,
      centerX, centerY,
      radius, scale = 4, maxDepth = 0;

  // Capture events
  var resize = function(){
    width   = sunburst.el.clientWidth > 900 ? 900 : sunburst.el.clientWidth;
    height  = width * 4/5;
    centerX = width / 2;
    centerY = 75 + height / 2;
    radius  = height / scale;
    explanation.setAttribute("style","margin-top:"+ (32.5 + height/2)+"px");
    data.setAttribute("style","max-width:"+ (height / (scale - 1)) +"px");
    render();
  }

  var mouseover = function(node){
    var p;
    percentage.innerText = ((p = (100 * node.value / totalSize).toPrecision(3)) < 0.1) ? 
      "< 0.1%" : p + "%";
    data.innerText = node.name;
    updateBreadcrumbs(node.path);
    for (var i = list.length - 1; i >= 0; i--) {
      if(node.path.indexOf(list[i]) == -1){
        list[i].element.setAttribute("style",'opacity:0.3');
      }
    };
  }

  var click = function(node){
    activated = true;
    active = node;
    display(active.index = 0);
  }

  function display(index){
    modal.setAttribute("style","display:block");
    var req = new XMLHttpRequest();
    req.onload = function(){
      message.innerText = JSON.parse(req.response).message;
      progress.innerText = (index+1)+"/"+(active.indices.length);
    }
    req.open("GET", "/api/" + raw + "/" + active.indices[index]);
    req.send();
  }

  // Guess we need a data structure. Build partition simultaneously
  var Node = function(name,parent,indices,weight){
    this.name = name;
    this.parent = parent;
    this.index  = 0;
    this.indices  = indices;
    this.value = weight;
    this.children = [];
    this.isRoot = false;

    if (parent){
      this.depth = parent.depth + 1;
      maxDepth = Math.max(maxDepth,this.depth);
      parent.children.push(this);
      this.element = createPath(this);

      // for positioning
      this.used    = 0;
      parent.used += weight;

      // Leave a trail
      this.path = parent.path.slice()
      this.path.push(this);
    }else{
      this.depth  = 0;
      this.isRoot = true;
      this.path   = [];
    }
  }

  Node.prototype.angle = function(angle) {
    return angle + 2*Math.PI*this.value/totalSize;
  };
    
  function colors(angle, depth) {
    var top = 255 -  5 * maxDepth,
      base = depth * 5,
      color = (angle/(2*Math.PI)) * top * 3,
      c = color | 0,
      x = top,
      y = c % top  + base,
      z = top - y  + base * 2;

    return "#" + [[z,y,x],
                  [y,x,z],
                  [x,z,y]][((color/top) | 0)%3]
    .map(function(c){return (c<16?"0":"") + c.toString(16)}).join("");
  };

  function polarToCartesian(r, angle) {
    return {
      x: centerX + (r * Math.cos(angle)),
      y: centerY + (r * Math.sin(angle))
    };
  }

  function describeArc(depth, startAngle, endAngle){
    var r,x;
    return {
      R : r = radius+depth*((x=radius*(scale-2)/(1.5*maxDepth))+x*(0.25*(maxDepth-depth)/maxDepth)),
      start : polarToCartesian(r, Math.max(endAngle,startAngle)),
      end   : polarToCartesian(r, Math.min(endAngle,startAngle))
    }
  }

  function buildSegment(node, angle){
    var end      = node.angle(angle),
        arcSweep = Math.abs(end - angle) <= Math.PI ? 0 : 1,
        outer    = describeArc(node.depth+1, angle, end),
        inner    = describeArc(node.depth, angle, end);

    set(node.element,"d",[
        "M", outer.start.x, outer.start.y,
        "A", outer.R, outer.R, 0, arcSweep, 0, outer.end.x, outer.end.y,
        "L", inner.end.x, inner.end.y,
        "A", inner.R, inner.R, 0, arcSweep, 1, inner.start.x, inner.start.y,
        "Z"
    ].join(" "));

    set(node.element, "fill", colors(isNaN(c=(end + angle)/2)?0:c, node.depth));

    return end;
  }

  // Main function to draw and set up the visualization, once we have the data.
  function render() {
    recurse(root.children,0);
    clear();
  };

  function clear(){
    if(activated) return;
    modal.setAttribute("style","");
    percentage.innerText = "100%";
    data.innerText = title;
    // Scrap it
    trail.innerHTML = null;
    for (var i = list.length - 1; i >= 0; i--) {
        list[i].element.setAttribute("style","");
    };
  }

  // Update the breadcrumb trail to show the current sequence and percentage.
  function updateBreadcrumbs(nodes) {
    // Some vars
    var b = 50, h = 30, s = 3, t = 10,
        transform = 0;

    // Hansel and Gretel
    for (var i = 0; i < nodes.length; i++) {
      var crumb = group.cloneNode(true);
      $(crumb,"polygon").setAttribute("points",[
          "0,0",
          (w = b + nodes[i].name.length * 5.5) + ",0", 
          w + t + "," + h / 2,
          w + "," + h,
          "0," + h,
          i > 0 ? t + "," + h / 2 : ""
      ].join(" "));
      set($(crumb,"polygon"), "fill",nodes[i].element.attributes.fill.value);
      $(crumb,"text").textContent = nodes[i].name;
      set(crumb, "transform", "translate("+ transform +", 0)");
      transform += w + s;

      // Add it to the trail
      trail.appendChild(crumb)
    };
  }

  function recurse(children, end){
    for (var count = children.length,i = count - 1; i >= 0; i--) {
      var current = children[i];
      recurse(
        children[i].children,
        end + 2*Math.PI*(children[i].value - children[i].used)/(2*totalSize)
      );
      end = buildSegment(current, end);
    }
  }

  function createPath(node){
    var el = path.cloneNode();
    el.addEventListener("mouseover", scope(node, mouseover));
    el.addEventListener("mouseout", scope(node, clear));
    el.addEventListener("click", scope(node, click));
    g.appendChild(el);
    return el;
  }

  // If produced from csvrecurions.m then the nodes will be ordered in such a way that this will be gravy
  // Takes a 3-column CSV and transform it into a hierarchical structure suitable
  function build(csv) {
    root = new Node('root', null, [], 65, -1);
    for (var i = 0; i < csv.length; i++) {
      var parts   = csv[i][0].split("-");
      var weight  = +csv[i][1];

      // Parse indices into integers
      var indices = csv[i][2]
        .split('-')
        .map(function(n){
          return +n;
        }).filter(function(n) {
          return n > 0;
        })
      
      var parent = null;
      if (parts.length > 1){
        parent = tree[parts[parts.length-2]];
        total += 1;
      }else{
        parent = root;
        totalSize += weight;
      }

      var name = parts[parts.length-1];
      var current = new Node(name, parent, indices, weight);
      tree[name] = current;
      list.push(current);
    }
    return root;
  }

  // Kick it off.. Almost got rid of d3
  d3.text(sunburst.file, function(text) {
    build(d3.csv.parseRows(text));
    window.onresize = resize;
    resize();
  });

  // Attach listeners
  modal.addEventListener("click", function(evt){
    if(!(activated = evt.target != modal)) clear();
  });
  left.addEventListener("click", function(){
    display(active.index == 0? active.index :--active.index)
  });
  right.addEventListener("click", function(){
    display(active.index == active.indices.length - 1 ? active.index :++active.index)
  });
}