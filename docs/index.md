---
sql:
  treeStatus: ./data/tree_status.csv
  fires: ./data/fire_info.csv
---

# Tree mortality post-wildfire

## Data: Cansler et al. (2020). The fire and tree mortality database. DOI: https://doi.org/10.2737/RDS-2020-0001

```js
const treeSpecies = view(
  Inputs.radio(
    ["White fir", "Lodgepole pine", "Ponderosa pine", "Douglas fir"],
    { unique: true, value: "White fir" }
  )
);
```

```sql id=treeFireJoin display
SELECT yr_fire_name
  , common_name
  , CAST(yr_post_fire AS INTEGER) as yr_post_fire
  , status
FROM treeStatus
JOIN fires on fires.YrFireName = treeStatus.yr_fire_name
WHERE common_name = ${treeSpecies}
```

```js
display([...treeFireJoin]);
```

```js
const treeSurvival = Plot.plot({
  marginLeft: 50,
  color: { legend: true },
  marks: [
    Plot.barY(
      treeFireJoin,
      Plot.groupX({ y: "count" }, { x: "yr_post_fire", fill: "status" })
    ),
  ],
});

display(treeSurvival);
```
