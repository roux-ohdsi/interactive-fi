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
  
const fi = vafi_all2.concat(efi_all2)
  
```

```js
//Inputs.table(vafi_all2)
```


```js
const lb = Inputs.radio(["static lookback", "variable lookback"], {label: "Lookback period:", value: "static lookback"});
const lb_data = Generators.input(lb);
```

```js

const vafi_sex_plot = Plot.plot({
      title: "VAFI Frailty Scores by Data Source and reported sex",
      marginBottom: 60,
      x: {
           type: "point",
           domain: ["[40,45)","[45,50)","[50,55)","[55,60)","[60,65)","[65,70)","[70,75)","[75,80)","[80,120]"],
           grid: true
        },
      fill: {
                legend: false,
                type: "categorical"//,
               // scheme: "Tableau10"//,
                //range: ["green", "yellow", "red"]
                //domain: "def"
              },
      color: {legend: false,
              type: "categorical",
              //scheme: "Tableau10",
              //domain: ["var1", "var2", "var3"],
              range: ["#FF725C", "#EFB118", "#3CA951"]
              },
      y: {domain: [0,100], percent: true},
      width,
      symbol: {legend: false,  range: ["square", "triangle"]},
      facet: {data: vafi_all2,
              x: "source",
              label: null
              },
      marks: [
         //Plot.frame({fx: "AOU", fill: "#ff725c10"}),
         //Plot.frame({fx: "Pharmetrics", fill: "#ff725c10"}),
         //Plot.frame({fx: "IMRD EMIS", fill: "#4269d010"}),
         //Plot.frame({fx: "IMRD UK", fill: "#4269d010"}),
         //Plot.frame({fx: "UKBB", fill: "#4269d010"}),
         Plot.ruleY([0]),
         //Plot.ruleX(["[140]"], {stroke: "red", fx: ["Pharmetrics"]}),
         Plot.dot(vafi_all2, {x: "age_group", filter: (d) => d.lb == lb_data,
                                    y: "score",
                                    stroke: "#FFF",
                                    channels: {country: 'country'},
                                    fx:"source", sort: {fx: "-country"},
                                    symbol: "sex",
                                    fill: "var",
                                    r: 5,
                                    tip: true}),
        Plot.lineY(vafi_all2, {x: "age_group",
                                   filter: (d) => d.lb == lb_data,
                                   sort: "age_group",
                                    y: "score",
                                    stroke: "var",
                                    strokeOpacity: 0.5,channels: {country: 'country'},
                                    fx:"source", sort: {fx: "-country"}
                                    }),
//        Plot.dot(efi_all, {x: "age_group",filter: (d) => d.lb == lb_data,
//                                    y: "score",
//                                    stroke: "#FFF",channels: {country: 'country'},
//                                    fx:"source", sort: {fx: "-country"},
//                                    symbol: "fi",
//                                    fill: "var",
//                                    r: 5,
//                                    tip: true}),
//        Plot.lineY(efi_all, {x: "age_group",filter: (d) => d.lb == lb_data,
//                                   sort: "age_group",
//                                    y: "score",
//                                    stroke: "var",
//                                    //strokeDasharray: "4, 6",
//                                    strokeOpacity: 0.5,channels: {country: 'country'},
//                                    fx:"source", sort: {fx: "-country"}
//                                    }),
        Plot.axisX({tickRotate: -45, label: "Age Group"}),
        Plot.axisY({label: "Incidence (%)"})
        
        ]
    })


```


```js

const efi_sex_plot = Plot.plot({
      title: "eFI Frailty Scores by Data Source and Reported Sex",
      marginBottom: 60,
      x: {
           type: "point",
           domain: ["[40,45)","[45,50)","[50,55)","[55,60)","[60,65)","[65,70)","[70,75)","[75,80)","[80,120]"],
           grid: true
        },
      fill: {
                legend: false,
                type: "categorical"//,
               // scheme: "Tableau10"//,
                //range: ["green", "yellow", "red"]
                //domain: "def"
              },
      color: {legend: false,
              type: "categorical",
              //scheme: "Tableau10",
              //domain: ["var1", "var2", "var3"],
              range: ["#FF725C", "#EFB118", "#3CA951"]
              },
      y: {domain: [0,100], percent: true},
      width,
      symbol: {legend: false, range: ["square", "triangle"]},
      facet: {data: efi_all2,
              x: "source",
              label: null
              },
      marks: [
         //Plot.frame({fx: "AOU", fill: "#ff725c10"}),
         //Plot.frame({fx: "Pharmetrics", fill: "#ff725c10"}),
         //Plot.frame({fx: "IMRD EMIS", fill: "#4269d010"}),
         //Plot.frame({fx: "IMRD UK", fill: "#4269d010"}),
         //Plot.frame({fx: "UKBB", fill: "#4269d010"}),
         Plot.ruleY([0]),
         //Plot.ruleX(["[140]"], {stroke: "red", fx: ["Pharmetrics"]}),
         Plot.dot(efi_all2, {x: "age_group", filter: (d) => d.lb == lb_data,
                                    y: "score",
                                    stroke: "#FFF",
                                    channels: {country: 'country'},
                                    fx:"source", sort: {fx: "-country"},
                                    symbol: "sex",
                                    fill: "var",
                                    r: 5,
                                    tip: true}),
        Plot.lineY(efi_all2, {x: "age_group",
                                   filter: (d) => d.lb == lb_data,
                                   sort: "age_group",
                                    y: "score",
                                    stroke: "var",
                                    strokeOpacity: 0.5,channels: {country: 'country'},
                                    fx:"source", sort: {fx: "-country"}
                                    }),
//        Plot.dot(efi_all, {x: "age_group",filter: (d) => d.lb == lb_data,
//                                    y: "score",
//                                    stroke: "#FFF",channels: {country: 'country'},
//                                    fx:"source", sort: {fx: "-country"},
//                                    symbol: "fi",
//                                    fill: "var",
//                                    r: 5,
//                                    tip: true}),
//        Plot.lineY(efi_all, {x: "age_group",filter: (d) => d.lb == lb_data,
//                                   sort: "age_group",
//                                    y: "score",
//                                    stroke: "var",
//                                    //strokeDasharray: "4, 6",
//                                    strokeOpacity: 0.5,channels: {country: 'country'},
//                                    fx:"source", sort: {fx: "-country"}
//                                    }),
        Plot.axisX({tickRotate: -45, label: "Age Group"}),
        Plot.axisY({label: "Incidence (%)"})
        
        ]
    })


```


<center><h1>OHDSI Frailty Study</h1></center>

<div class="grid grid-cols-1">
  <div class="card">
    ${[lb]}
  </div>
</div>
  
<div class="grid grid-cols-1">

  <div class="card">
    ${resize((width) => vafi_sex_plot)}
    <div style = "float:right;display:inline;">
      <div style="display:inline-block;margin-right: 20px;">${vafi_sex_plot.legend("color")}</div>
      <div style="display:inline-block;">${vafi_sex_plot.legend("symbol")}</div>
    </div>
  </div>
  
  <div class="card">
    ${resize((width) => efi_sex_plot)}
    <div style = "float:right;display:inline;">
      <div style="display:inline-block;margin-right: 20px;">${efi_sex_plot.legend("color")}</div>
      <div style="display:inline-block;">${efi_sex_plot.legend("symbol")}</div>
    </div>
  </div>
  
</div>



```js
const fi_categories_dat = FileAttachment("data/fi_categories.csv").csv({typed: true}).catch(() => console.error("unable to load fi cats csv"));
```

```js
const vafi_categories_all = aq.from(fi_categories_dat)
  .filter(aq.escape((d) => d.sex == "All" && d.fi == "vafi")) // & d.lb == lb2

  
const efi_categories_all = aq.from(fi_categories_dat)
  .filter(aq.escape((d) => d.sex == "All" && d.fi == "efi")) // & d.lb == lb2)
  
//const fi_categories = vafi_categories_all.concat(efi_categories_all)
```


```js
const selected_efi = Inputs.select(d3.group(efi_categories_all, (d) => d.category),{label: "Select Category"});
const selected_efi_data = Generators.input(selected_efi);

const selected_vafi = Inputs.select(d3.group(vafi_categories_all, (d) => d.category),{label: "Select Category"});
const selected_vafi_data = Generators.input(selected_vafi);

const y_lim = Inputs.range([0, 1], {label: "y-axis limits", step: 0.1,  value: 0.5});
const ylim_data = Generators.input(y_lim);

const observable5 = [
  "#4269d0", // blue
  "#efb118", // orange
  "#ff725c", // red
  //"#6cc5b0", // cyan
  "#3ca951", // green
  //"#ff8ab7", // pink
  "#a463f2" // purple
  //"#97bbf5", // light blue
 // "#9c6b4e", // brown
 // "#9498a0"  // gray
]
```

<div class="grid grid-cols-2">

  <div class="card">
    ${selected_vafi}
    <br>
  ${resize((width) => 
    Plot.plot({
      title: "VAFI category incidence by data source",
      marginBottom: 60,
      y: {domain: [0, 1]},
      x: {
           type: "point",
           domain: ["[40,45)","[45,50)","[50,55)","[55,60)","[60,65)","[65,70)","[70,75)","[75,80)","[80,120]"],
           grid: true
        },
      y: {domain: [0, ylim_data]},
      fill: {
                legend: false,
                type: "categorical",
                scheme: "Dark2",
                //domain: "def"
              },
      color: {legend: true,
              range: ["#4269d0", // blue
                      "#efb118", // orange
                      "#ff725c", // red
                      "#3ca951", // green
                      "#a463f2" // purple
                      ]},
      width,
      symbol: {legend: false},
      marks: [
         Plot.ruleY([0]),
         Plot.dot(selected_vafi_data, {x: "age_group",filter: (d) => d.lb == lb_data,
                                    y: "prop",
                                    stroke: "#FFF",
                                    //fx:"source",
                                    //symbol: "fi",
                                    fill: "source",
                                    r: 5,
                                    tip: true}),
        Plot.lineY(selected_vafi_data, {x: "age_group",filter: (d) => d.lb == lb_data,
                                   sort: "age_group",
                                    y: "prop",
                                    stroke: "source",
                                    strokeOpacity: 0.5,
                                    //fx:"source"
                                    }),
        Plot.axisX({tickRotate: -45})
        ]
    }))
  }
  
  

  
  </div>
  
  
  <div class="card">
  ${selected_efi}
      <br>
  ${resize((width) => 
    Plot.plot({
      title: "eFI category incidence by data source",
      marginBottom: 60,
      x: {
           type: "point",
           domain: ["[40,45)","[45,50)","[50,55)","[55,60)","[60,65)","[65,70)","[70,75)","[75,80)","[80,120]"],
           grid: true
        },
      y: {domain: [0, ylim_data]},
      fill: {
                legend: false,
                type: "categorical",
                scheme: "Dark2",
                //domain: "def"
              },
      color: {legend: true,
              range: ["#4269d0", // blue
                      "#efb118", // orange
                      "#ff725c", // red
                      "#3ca951", // green
                      "#a463f2" // purple
                      ]},
      width,
      symbol: {legend: false},
      marks: [
         Plot.ruleY([0]),
        Plot.dot(selected_efi_data, {x: "age_group",filter: (d) => d.lb == lb_data,
                                    y: "prop",
                                    stroke: "#FFF",
                                    //fx:"source",
                                    //symbol: "fi",
                                    fill: "source",
                                    r: 5,
                                    tip: true}),
        Plot.lineY(selected_efi_data, {x: "age_group",filter: (d) => d.lb == lb_data,
                                   sort: "age_group",
                                    y: "prop",
                                    stroke: "source",
                                    //strokeDasharray: "4, 6",
                                    strokeOpacity: 0.5,
                                    //fx:"source"
                                    }),
        Plot.axisX({tickRotate: -45})
        ]
    }))
  }
  </div>
  
</div>

<center>${[y_lim]}</center>

