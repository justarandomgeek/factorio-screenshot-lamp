local p = table.deepcopy(data.raw["lamp"]["small-lamp"])
p.name = "screenshot-lamp"
p.minable.result = "screenshot-lamp"
data:extend{p}
