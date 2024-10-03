---
title: "OHDSI Frailty Study"
toc: false
theme: [air, alt]
---



```js
const fi_dat = FileAttachment("data/fi.csv").csv({typed: true}).catch(() => console.error("unable to load vafi csv"));
//const fi_categories_dat = FileAttachment("data/fi_categories.csv").csv({typed: true}).catch(() => console.error("unable to load efi csv"));
```

```js
const vafi_all = aq.from(fi_dat)
  .filter(aq.escape((d) => d.sex == "All" & d.fi == "vafi")) // & d.lb == lb
  .fold(['frail', 'prefrail', "robust"], { as: ['var', 'score'] })
  //.derive({ fi: d => "vafi" })
  //.derive({ score: d => d.score/100})

  
const efi_all = aq.from(fi_dat)
  .filter(aq.escape((d) => d.sex == "All" & d.fi == "efi")) //& d.lb == lb
  .fold(['frail', 'prefrail', "robust"], { as: ['var', 'score'] })
  //.derive({ fi: d => "efi" })
  //.derive({ score: d => d.score/100})
  
const fi = vafi_all.concat(efi_all)
  
```

```js
const lb = Inputs.radio(["1-year lookback", "3-year lookback"], {label: "UK Lookback period:", value: "1-year lookback"});
const lb_data = Generators.input(lb);


const meas = Inputs.radio(["yes", "no"], {label: "Include eFI measurements (UK only)", value: "no"});
const meas_data = Generators.input(meas)
```

```js

const all_plot = Plot.plot({
      title: "Frailty Scores by Data Source",
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
      symbol: {legend: false},
      facet: {data: vafi_all,
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
         Plot.dot(vafi_all, {x: "age_group", filter: (d) => d.lb == lb_data & d.meas == meas_data,
                                    y: "score",
                                    stroke: "#FFF",
                                    channels: {country: 'country'},
                                    fx:"source", sort: {fx: "-country"},
                                    symbol: "fi",
                                    fill: "var",
                                    r: 5,
                                    tip: true}),
        Plot.lineY(vafi_all, {x: "age_group",filter: (d) => d.lb == lb_data & d.meas == meas_data,
                                   sort: "age_group",
                                    y: "score",
                                    stroke: "var",
                                    strokeOpacity: 0.5,channels: {country: 'country'},
                                    fx:"source", sort: {fx: "-country"}
                                    }),
        Plot.dot(efi_all, {x: "age_group",filter: (d) => d.lb == lb_data & d.meas == meas_data,
                                    y: "score",
                                    stroke: "#FFF",channels: {country: 'country'},
                                    fx:"source", sort: {fx: "-country"},
                                    symbol: "fi",
                                    fill: "var",
                                    r: 5,
                                    tip: true}),
        Plot.lineY(efi_all, {x: "age_group",filter: (d) => d.lb == lb_data & d.meas == meas_data,
                                   sort: "age_group",
                                    y: "score",
                                    stroke: "var",
                                    //strokeDasharray: "4, 6",
                                    strokeOpacity: 0.5,channels: {country: 'country'},
                                    fx:"source", sort: {fx: "-country"}
                                    }),
        Plot.axisX({tickRotate: -45, label: "Age Group"}),
        Plot.axisY({label: "Prevalence (%)"})
        
        ]
    })


```


<center><h1>OHDSI Frailty Study</h1></center>

<div class="grid grid-cols-1">
  <div class="card">
    ${[lb, meas]}
  </div>
</div>
  
<div class="grid grid-cols-1">

  <div class="card">
    ${resize((width) => all_plot)}
    <div style = "float:right;display:inline;">
      <div style="display:inline-block;margin-right: 20px;">${all_plot.legend("color")}</div>
      <div style="display:inline-block;">${all_plot.legend("symbol")}</div>
    </div>
  </div>
  
</div>


