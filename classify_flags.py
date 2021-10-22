import glob
import pandas as pd
import colorgram

all_countries = glob.glob("flagpngs/*")

basecols = {'red': [255, 0, 0], 'green' : [0, 255, 0], 'blue': [0, 0, 255],
            'orange': [255, 152, 0], 'yellow': [255, 255, 0]}

working_final = pd.DataFrame({})

for x in all_countries:
    vals, cols, count, prop = [], [], [], []
    fn = x
    country_name = x.split("/")[1]
    country_name = country_name.split("_")[0]
    colors = colorgram.extract(fn, 6)
    for y in range(len(colors)):
        if colors[y].proportion > 0.05:
            col = colors[y].rgb
            if sum(col) == 0:
                cols.append('black')
                prop.append(colors[y].proportion)
                vals.append(0)
                count.append(y)
            if sum(col) >= 248 * 3:
                cols.append('white')
                prop.append(colors[y].proportion)
                vals.append(0)
                count.append(y)
            col = [z + 1 for z in col]
            for a in basecols:
                vals.append(sum([abs(basecols[a][0]-col[0]), abs(basecols[a][1]-col[1]), abs(basecols[a][2]-col[2])]))
                cols.append(a)
                count.append(y)
                prop.append(colors[y].proportion)

    country_final = pd.DataFrame({'values' : vals, 'colors' : cols,\
            'count': count, 'proportion' : prop, 'country': country_name})
    temp_df = country_final.loc[country_final.groupby('count').values.idxmin()]
    working_final = working_final.append(temp_df)

working_final.to_csv("colorgram_cols.csv", index=False)
