---
title: "OHDSI Frailty Study - Categories"
toc: false
theme: [air, alt]
---



```js
const vafi = FileAttachment("data/vafi.csv").csv({typed: true}).catch(() => console.error("unable to load vafi csv"));
const vafi_categories = FileAttachment("data/vafi_categories.csv").csv({typed: true}).catch(() => console.error("unable to load vafi_categories csv"));

const vafi = FileAttachment("data/vafi.csv").csv({typed: true}).catch(() => console.error("unable to load vafi csv"));
const vafi_categories = FileAttachment("data/vafi_categories.csv").csv({typed: true}).catch(() => console.error("unable to load vafi_categories csv"));

```

```js
const selected_dataInput = Inputs.select(d3.group(vafi_categories, (d) => d.category),{label: "Select Category"});
const selected_data = Generators.input(selected_dataInput);

const selected_dataInput2 = Inputs.select(d3.group(vafi_categories, (d) => d.category),{label: "Select Category"});
const selected_data2 = Generators.input(selected_dataInput2);
```

<center><h1>OHDSI Frailty Study</h1></center>
<center><h2>VAFI</h2></center>

<div class="grid grid-cols-1">

<div class="card" style="max-width:none;">

${
  Plot.plot({
    title: "Frailty scores by Data Source",
    marginBottom: 60,
    x: {
         type: "point",
         domain: ["[40,45)","[45,50)","[50,55)","[55,60)","[60,65)","[65,70)","[70,75)","[75,80)","[80,120]"],
         grid: true
      },
    //y: {percent: true},
    color: {legend: true},
    //max-width: "none",
    style: {maxWidth: "2800px", width: "1000px"},
    marks: [
       Plot.ruleY([0]),
       Plot.dot(vafi_all, {x: "age_group",
                                  y: "score",
                                  stroke: "var",
                                  fx:"source",
                                  tip: true}),
      Plot.lineY(vafi_all, {x: "age_group",
                                 sort: "age_group",
                                  y: "score",
                                  stroke: "var",
                                  fx:"source"
                                  }),
      Plot.axisX({tickRotate: -45}),
    ]
  })
}

</div>

<div class="card" style="display:none;">

${
  Plot.plot({
    title: "Proportion of Frail by Age Group",
    marginBottom: 60,
    x: {
         type: "point",
         domain: ["[40,45)","[45,50)","[50,55)","[55,60)","[60,65)","[65,70)","[70,75)","[75,80)","[80,120]"],
         grid: true
      },
    //y: {percent: true},
    color: {legend: true},
    marks: [
       Plot.ruleY([0]),
       Plot.dot(vafi, {x: "age_group",
                                  y: "frail",
                                  stroke: "source",
                                  fx:"sex",
                                  tip: true}),
      Plot.lineY(vafi, {x: "age_group",
                                 sort: "age_group",
                                  y: "frail",
                                  stroke: "source",
                                  fx:"sex"}),
      Plot.axisX({tickRotate: -45}),
    ]
  })
}
</div>

<div class="card">
${selected_dataInput}
<br>
${
  Plot.plot({
    title: "Propotion of " + selected_data[1].category + " by Age Group",
    marginBottom: 60,
    x: {
         type: "point",
         domain: ["[40,45)","[45,50)","[50,55)","[55,60)","[60,65)","[65,70)","[70,75)","[75,80)","[80,120]"],
         grid: true
      },
    y: {percent: true},
    color: {legend: true},
    marks: [
       Plot.ruleY([0]),
       Plot.dot(selected_data, {x: "age_group",
                                  y: "prop",
                                  stroke: "source",
                                  fx:"sex",
                                  tip: true}),
      Plot.lineY(selected_data, {x: "age_group",
                                 sort: "age_group",
                                  y: "prop",
                                  stroke: "source",
                                  fx:"sex"}),
      Plot.axisX({tickRotate: -45}),
    ]
  })
}
</div>

<div class="card">
${selected_dataInput2}
<br>
${
  Plot.plot({
    title: "Propotion of " + selected_data2[1].category + " by Age Group",
    marginBottom: 60,
    x: {
         type: "point",
         domain: ["[40,45)","[45,50)","[50,55)","[55,60)","[60,65)","[65,70)","[70,75)","[75,80)","[80,120]"],
         grid: true
      },
    y: {percent: true},
    color: {legend: true},
    marks: [
       Plot.ruleY([0]),
       Plot.dot(selected_data2, {x: "age_group",
                                  y: "prop",
                                  stroke: "source",
                                  fx:"sex",
                                  tip: true}),
      Plot.lineY(selected_data2, {x: "age_group",
                                 sort: "age_group",
                                  y: "prop",
                                  stroke: "source",
                                  fx:"sex"}),
      Plot.axisX({tickRotate: -45}),
    ]
  })
}
</div>

</div>
