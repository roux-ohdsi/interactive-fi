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
  </div>
</div>

