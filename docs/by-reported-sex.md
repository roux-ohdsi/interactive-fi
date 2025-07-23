---
title: "Results by Reported Sex"
toc: false
theme: [air, alt]
---



```js
const fi_dat = FileAttachment("data/fi.csv").csv({typed: true}).catch(() => console.error("unable to load vafi csv"));
//const fi_categories_dat = FileAttachment("data/fi_categories.csv").csv({typed: true}).catch(() => console.error("unable to load efi csv"));
```

```js
const vafi_all2 = aq.from(fi_dat)
  .filter(aq.escape((d) => d.sex != "All" & d.fi == "vafi")) // & d.lb == lb
  .fold(['frail', 'prefrail', "robust"], { as: ['var', 'score'] })
  .orderby('lb', 'fi', 'source', 'sex', 'age_group')

  //.derive({ fi: d => "vafi" })
  //.derive({ score: d => d.score/100})

  
const efi_all2 = aq.from(fi_dat)
  .filter(aq.escape((d) => d.sex != "All" & d.fi == "efi")) //& d.lb == lb
  .fold(['frail', 'prefrail', "robust"], { as: ['var', 'score'] })
  .orderby('lb', 'fi', 'source', 'sex', 'age_group')

  //.derive({ fi: d => "efi" })
  //.derive({ score: d => d.score/100})
  
const fi_all = vafi_all2.concat(efi_all2)
  
```


```js
const lb = Inputs.radio(["1-year lookback", "3-year lookback"], {label: "UK Lookback period:", value: "1-year lookback"});
const lb_data = Generators.input(lb);

const choose_fi = Inputs.radio(["vafi", "efi"], {label: "Frailty Index:", value: "vafi"});
const choose_fi_data = Generators.input(choose_fi);

const meas = Inputs.radio(["yes", "no"], {label: "Include eFI measurements (UK only)", value: "no"});
const meas_data = Generators.input(meas)
```

```js

const vafi_sex_plot = Plot.plot({
      title: "Frailty Scores by Data Source and reported sex - " + choose_fi_data,
      marginBottom: 60,
      x: {
           //type: "point",
           //domain: ["[40,45)","[45,50)","[50,55)","[55,60)","[60,65)","[65,70)","[70,75)","[75,80)","[80,100]"],
           grid: true
        },
      fill: {
                legend: false,
                type: "categorical"
              },
      color: {legend: false,
              type: "categorical",
              range: ["#FF725C", "#EFB118", "#3CA951"]
              },
      y: {domain: [0,100], percent: true},
      width,
      symbol: {legend: false,  range: ["square", "triangle"]},
      facet: {data: fi_all,
              x: "source",
              label: null
              },
      marks: [
         
         Plot.ruleY([0]),
         Plot.dot(fi_all, {x: "age_group", filter: (d) => d.lb == lb_data & d.fi == choose_fi_data & d.meas == meas_data,
                                y: "score",
                                //stroke: "#FFF",
                                channels: {country: 'country'},
                                fx:"source", sort: {fx: "-country"},
                                symbol: "sex",
                                fill: "var",
                                r: 3,
                                    tip: true}),
        Plot.lineY(fi_all, {x: "age_group",
                                   filter: (d) => d.lb == lb_data & d.fi == choose_fi_data & d.meas == meas_data,
                                    //sort: "age_group",
                                    y: "score",
                                    stroke: "var",
                                    //fill: "var",
                                    //symbol: "sex",
                                    z: (d) => `${d.var} ${d.sex}`,
                                    strokeOpacity: 0.5, //channels: {country: 'country'},
                                    fx:"source" //sort: {fx: "-country"},
                                    }),
        Plot.axisX({tickRotate: -45, label: "Age Group"}),
        Plot.axisY({label: "Prevalence (%)"})
        
        ]
    })


```

<center><h1>OHDSI Frailty Study</h1></center>
<div class="grid grid-cols-1">
  <div class="card">
    ${[lb, choose_fi, meas]}
  </div>
</div>
  
<div class="grid grid-cols-1">
  <div class="card" id="plotContainer">
    ${resize((width) => vafi_sex_plot)}
    <div style="float:right;display:inline;" id="legendContainer">
      <div style="display:inline-block;margin-right: 20px;">${vafi_sex_plot.legend("color")}</div>
      <div style="display:inline-block;">${vafi_sex_plot.legend("symbol")}</div>
    </div>
    <!-- Add download button for sex plot -->
    <div style="text-align:left;margin-top:15px;clear:both;">
      <button id="downloadPlotOnlyBtn" style="padding:8px 16px;background-color:#4CAF50;color:white;border:none;border-radius:4px;cursor:pointer;margin-right:10px;">
        Download Plot Only
      </button>
      <button id="downloadWithLegendsBtn" style="padding:8px 16px;background-color:#3ca951;color:white;border:none;border-radius:4px;cursor:pointer;">
        Try With Legends
      </button>
      <label style="margin-left: 10px;">
        Scale: 
        <select id="exportScale" style="padding: 6px; border-radius: 4px; border: 1px solid #ccc;">
          <option value="1">1x (Original)</option>
          <option value="1.5" selected>1.5x</option>
          <option value="2">2x</option>
          <option value="3">3x</option>
        </select>
      </label>
    </div>
  </div>
</div>

<script>
// Download plot only (original working method)
document.getElementById('downloadPlotOnlyBtn').onclick = function() {
  const svg = document.querySelector('.card svg');
  if (!svg) {
    console.error("Could not find SVG element");
    return;
  }
  
  // Get the selected scale factor
  const scaleFactor = parseFloat(document.getElementById('exportScale').value);
  
  try {
    // Get SVG data
    const svgData = new XMLSerializer().serializeToString(svg);
    
    // Add white background to SVG
    const parser = new DOMParser();
    const svgDoc = parser.parseFromString(svgData, "image/svg+xml");
    const svgElement = svgDoc.documentElement;
    
    // Create a white background rectangle
    const rect = document.createElementNS("http://www.w3.org/2000/svg", "rect");
    rect.setAttribute("width", "100%");
    rect.setAttribute("height", "100%");
    rect.setAttribute("fill", "white");
    
    // Insert the rectangle as the first child of the SVG
    if (svgElement.firstChild) {
      svgElement.insertBefore(rect, svgElement.firstChild);
    } else {
      svgElement.appendChild(rect);
    }
    
    // Serialize the modified SVG
    const modifiedSvgData = new XMLSerializer().serializeToString(svgDoc);
    const svgBlob = new Blob([modifiedSvgData], {type: "image/svg+xml;charset=utf-8"});
    
    // Create image from SVG
    const DOMURL = window.URL || window.webkitURL || window;
    const url = DOMURL.createObjectURL(svgBlob);
    
    const img = new Image();
    img.onload = function() {
      // Create canvas with white background and scaled dimensions
      const canvas = document.createElement("canvas");
      // Get the original dimensions
      const width = svg.getBoundingClientRect().width;
      const height = svg.getBoundingClientRect().height;
      
      // Scale the canvas dimensions
      canvas.width = width * scaleFactor;
      canvas.height = height * scaleFactor;
      
      const ctx = canvas.getContext("2d");
      
      // Fill canvas with white background
      ctx.fillStyle = "white";
      ctx.fillRect(0, 0, canvas.width, canvas.height);
      
      // Scale the context for rendering
      ctx.scale(scaleFactor, scaleFactor);
      
      // Draw the image on top
      ctx.drawImage(img, 0, 0);
      
      // Download PNG
      DOMURL.revokeObjectURL(url);
      
      canvas.toBlob(function(blob) {
        const pngUrl = DOMURL.createObjectURL(blob);
        const a = document.createElement("a");
        a.href = pngUrl;
        a.download = "frailty-by-sex.png";
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        DOMURL.revokeObjectURL(pngUrl);
      });
    };
    
    img.onerror = function() {
      console.error("Error loading image from SVG");
    };
    
    img.src = url;
  } catch (error) {
    console.error("Error in download process:", error);
  }
};

// Attempt to download with legends
document.getElementById('downloadWithLegendsBtn').onclick = function() {
  // Find the main SVG and legend SVGs
  const mainSvg = document.querySelector('.card > svg');
  const legendContainer = document.getElementById('legendContainer');
  
  if (!mainSvg || !legendContainer) {
    console.error("Could not find SVG or legend elements");
    alert("Could not capture plot with legends. Falling back to plot-only download.");
    document.getElementById('downloadPlotOnlyBtn').click();
    return;
  }
  
  // Use alert to notify about this functionality
  alert("Including legends in the download is experimental and may not work in all browsers. If you don't see legends in the downloaded image, please use the 'Download Plot Only' button instead.");
  
  try {
    // Get the selected scale factor
    const scaleFactor = parseFloat(document.getElementById('exportScale').value);
    
    // Get dimensions
    const mainSvgRect = mainSvg.getBoundingClientRect();
    const legendRect = legendContainer.getBoundingClientRect();
    
    // Create a canvas large enough for both
    const canvas = document.createElement('canvas');
    const combinedWidth = Math.max(mainSvgRect.width, legendRect.width);
    const combinedHeight = mainSvgRect.height + legendRect.height + 20; // Extra space between
    
    canvas.width = combinedWidth * scaleFactor;
    canvas.height = combinedHeight * scaleFactor;
    
    const ctx = canvas.getContext('2d');
    
    // Fill with white background
    ctx.fillStyle = 'white';
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    ctx.scale(scaleFactor, scaleFactor);
    
    // Function to convert SVG to image and draw on canvas
    function drawSvgToCanvas(svg, x, y, callback) {
      const svgData = new XMLSerializer().serializeToString(svg);
      const svgBlob = new Blob([svgData], {type: 'image/svg+xml;charset=utf-8'});
      const url = URL.createObjectURL(svgBlob);
      const img = new Image();
      
      img.onload = function() {
        ctx.drawImage(img, x, y);
        URL.revokeObjectURL(url);
        callback();
      };
      
      img.onerror = function() {
        console.error('Error loading SVG as image');
        URL.revokeObjectURL(url);
        callback(new Error('Failed to load SVG'));
      };
      
      img.src = url;
    }
    
    // Draw main SVG first
    drawSvgToCanvas(mainSvg, 0, 0, function(error) {
      if (error) {
        alert('Error creating image. Try the Plot Only option.');
        return;
      }
      
      // Get legend SVGs and convert to array
      const legendSvgs = legendContainer.querySelectorAll('svg');
      
      // If no legend SVGs, just download what we have
      if (legendSvgs.length === 0) {
        downloadCanvas();
        return;
      }
      
      // Get base position for legends
      let currentX = 10;
      const legendY = mainSvgRect.height + 10;
      
      // Function to draw all legends sequentially
      function drawNextLegend(index) {
        if (index >= legendSvgs.length) {
          // All legends drawn, download the canvas
          downloadCanvas();
          return;
        }
        
        const legendSvg = legendSvgs[index];
        const legendWidth = legendSvg.getBoundingClientRect().width;
        
        drawSvgToCanvas(legendSvg, currentX, legendY, function(error) {
          if (error) {
            // If error drawing legend, just download what we have
            downloadCanvas();
            return;
          }
          
          // Move to next legend position
          currentX += legendWidth + 20;
          drawNextLegend(index + 1);
        });
      }
      
      // Start drawing legends
      drawNextLegend(0);
    });
    
    // Function to download the canvas as PNG
    function downloadCanvas() {
      canvas.toBlob(function(blob) {
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'frailty-by-sex-with-legends.png';
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
      });
    }
  } catch (error) {
    console.error('Error preparing download:', error);
    alert('Error preparing download. Try the Plot Only option.');
  }
};
</script>