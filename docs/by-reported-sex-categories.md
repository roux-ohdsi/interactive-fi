---
title: "Results by Reported Sex"
toc: false
theme: [air, alt]
---


```js
const lb3 = Inputs.radio(["1-year lookback", "3-year lookback"], {label: "UK Lookback period:", value: "1-year lookback"});
const lb_data3 = Generators.input(lb3);
```


<center><h1>OHDSI Frailty Study</h1></center>

<div class="grid grid-cols-1">
  <div class="card">
    ${[lb3]}
  </div>
</div>



```js
const fi_categories_dat = FileAttachment("data/fi_categories.csv").csv({typed: true}).catch(() => console.error("unable to load fi cats csv"));
```

```js
const vafi_categories_all = aq.from(fi_categories_dat)
  .filter(aq.escape((d) => d.sex != "All" && d.fi == "vafi")) // & d.lb == lb2

const efi_categories_all = aq.from(fi_categories_dat)
  .filter(aq.escape((d) => d.sex != "All" && d.fi == "efi")) // & d.lb == lb2)
  
//const fi_categories = vafi_categories_all.concat(efi_categories_all)
```

```js
const selected_efi = Inputs.select(d3.group(efi_categories_all, (d) => d.category),{label: "Select Category"});
const selected_efi_data = Generators.input(selected_efi);

const selected_vafi = Inputs.select(d3.group(vafi_categories_all, (d) => d.category),{label: "Select Category"});
const selected_vafi_data = Generators.input(selected_vafi);

const y_lim = Inputs.range([0, 1], {label: "y-axis limits", step: 0.1,  value: 0.5});
const ylim_data = Generators.input(y_lim);


const meas = Inputs.radio(["yes", "no"], {label: "Include eFI measurements (UK only)", value: "no"});
const meas_data = Generators.input(meas);

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
           domain: ["[40,45)","[45,50)","[50,55)","[55,60)","[60,65)","[65,70)","[70,75)","[75,80)","[80,100]"],
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
      symbol: {legend: true},
      marks: [
         Plot.ruleY([0]),
         Plot.dot(selected_vafi_data, {
                                   x: "age_group",
                                   filter: (d) => d.lb == lb_data3 & d.meas == meas_data,
                                   y: "prop",
                                   stroke: "#FFF",
                                   symbol: "sex",
                                   fill: "source",
                                   r: 5,
                                   tip: true}),
        Plot.line(selected_vafi_data, {
                                    filter: (d) => d.lb == lb_data3 & d.meas == meas_data,
                                    x: "age_group",
                                    y: "prop",
                                    z: (d) => `${d.source} ${d.sex}`,
                                    stroke: "source",
                                    }),
        Plot.axisX({tickRotate: -45}),
        Plot.axisY({label: "Prevalence (%)"})
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
           domain: ["[40,45)","[45,50)","[50,55)","[55,60)","[60,65)","[65,70)","[70,75)","[75,80)","[80,100]"],
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
      symbol: {legend: true},
      marks: [
         Plot.ruleY([0]),
       Plot.dot(selected_efi_data, {
                                   x: "age_group",
                                   filter: (d) => d.lb == lb_data3 & d.meas == meas_data,
                                   y: "prop",
                                   stroke: "#FFF",
                                   symbol: "sex",
                                   fill: "source",
                                   r: 5,
                                   tip: true}),
        Plot.line(selected_efi_data, {
                                    filter: (d) => d.lb == lb_data3 & d.meas == meas_data,
                                    x: "age_group",
                                    y: "prop",
                                    z: (d) => `${d.source} ${d.sex}`,
                                    stroke: "source",
                                    }),
        Plot.axisX({tickRotate: -45}),
        Plot.axisY({label: "Prevalence (%)"})
        ]
    }))
  }
  </div>
  
</div>

<center>${[y_lim]}</center>