---
title: "OHDSI Frailty Study"
toc: false
theme: [air, alt]
---



```js
const vafi = FileAttachment("data/vafi.csv").csv({typed: true}).catch(() => console.error("unable to load vafi csv"));
const efi = FileAttachment("data/efi.csv").csv({typed: true}).catch(() => console.error("unable to load efi csv"));
```

```js
const vafi_all = aq.from(vafi)
  .filter((d) => d.sex == "All")
  .fold(['frail', 'prefrail', "robust"], { as: ['var', 'score'] })
  .derive({ fi: d => "vafi" })

  
const efi_all = aq.from(efi)
  .filter((d) => d.sex == "All")
  .fold(['frail', 'prefrail', "robust"], { as: ['var', 'score'] })
  .derive({ fi: d => "efi" })
  
const fi = vafi_all.concat(efi_all)
```

```js
//Inputs.table(vafi_all)
```

```js

const all_plot = Plot.plot({
      title: "Frailty Scores by data source",
      marginBottom: 60,
      x: {
           type: "point",
           domain: ["[40,45)","[45,50)","[50,55)","[55,60)","[60,65)","[65,70)","[70,75)","[75,80)","[80,120]"],
           grid: true
        },
      fill: {
                legend: false,
                type: "categorical",
                scheme: "Dark2",
                //domain: "def"
              },
      color: {legend: false},
      y: {domain: [0,1]},
      width,
      symbol: {legend: false},
      marks: [
         Plot.ruleY([0]),
         Plot.dot(vafi_all, {x: "age_group",
                                    y: "score",
                                    stroke: "#FFF",
                                    fx:"source",
                                    symbol: "fi",
                                    fill: "var",
                                    r: 5,
                                    tip: true}),
        Plot.lineY(vafi_all, {x: "age_group",
                                   sort: "age_group",
                                    y: "score",
                                    stroke: "var",
                                    strokeOpacity: 0.5,
                                    fx:"source"
                                    }),
        Plot.dot(efi_all, {x: "age_group",
                                    y: "score",
                                    stroke: "#FFF",
                                    fx:"source",
                                    symbol: "fi",
                                    fill: "var",
                                    r: 5,
                                    tip: true}),
        Plot.lineY(efi_all, {x: "age_group",
                                   sort: "age_group",
                                    y: "score",
                                    stroke: "var",
                                    //strokeDasharray: "4, 6",
                                    strokeOpacity: 0.5,
                                    fx:"source"
                                    }),
        Plot.axisX({tickRotate: -45})
        ]
    })


```

<center><h1>OHDSI Frailty Study</h1></center>
  
<div class="grid grid-cols-1">

  <div class="card">
    ${resize((width) => all_plot)}
    <div style = "float:right;display:inline;">
      <div style="display:inline-block;margin-right: 20px;">${all_plot.legend("color")}</div>
      <div style="display:inline-block;">${all_plot.legend("symbol")}</div>
    </div>
  </div>
  
</div>

```js
//const vafi = FileAttachment("data/vafi.csv").csv({typed: true}).catch(() => console.error("unable to load vafi csv"));
const vafi_categories = FileAttachment("data/vafi_categories.csv").csv({typed: true}).catch(() => console.error("unable to load vafi_categories csv"));

//const efi = FileAttachment("data/efi.csv").csv({typed: true}).catch(() => console.error("unable to load vafi csv"));
const efi_categories = FileAttachment("data/efi_categories.csv").csv({typed: true}).catch(() => console.error("unable to load efi_categories csv"));
```

```js
const vafi_categories_all = aq.from(vafi_categories)
  .filter((d) => d.sex == "All")

  
const efi_categories_all = aq.from(efi_categories)
  .filter((d) => d.sex == "All")
  
//const fi_categories = vafi_categories_all.concat(efi_categories_all)
```


```js
const selected_efi = Inputs.select(d3.group(efi_categories_all, (d) => d.category),{label: "Select Category"});
const selected_efi_data = Generators.input(selected_efi);

const selected_vafi = Inputs.select(d3.group(vafi_categories_all, (d) => d.category),{label: "Select Category"});
const selected_vafi_data = Generators.input(selected_vafi);

const y_lim = Inputs.range([0, 1], {label: "y-axis limits", step: 0.1,  value: 1});
const ylim_data = Generators.input(y_lim);
```

<div class="grid grid-cols-2">

  <div class="card">
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
      color: {legend: true},
      width,
      symbol: {legend: false},
      marks: [
         Plot.ruleY([0]),
         Plot.dot(selected_vafi_data, {x: "age_group",
                                    y: "prop",
                                    stroke: "#FFF",
                                    //fx:"source",
                                    //symbol: "fi",
                                    fill: "source",
                                    r: 5,
                                    tip: true}),
        Plot.lineY(selected_vafi_data, {x: "age_group",
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
  <br>
  ${selected_vafi}

  
  </div>
  
  
  <div class="card">
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
      color: {legend: true},
      width,
      symbol: {legend: false},
      marks: [
         Plot.ruleY([0]),
        Plot.dot(selected_efi_data, {x: "age_group",
                                    y: "prop",
                                    stroke: "#FFF",
                                    //fx:"source",
                                    //symbol: "fi",
                                    fill: "source",
                                    r: 5,
                                    tip: true}),
        Plot.lineY(selected_efi_data, {x: "age_group",
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
  <br>
  ${selected_efi}
  </div>
  
</div>

<center>${y_lim}</center>

```js

