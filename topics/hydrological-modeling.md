# Contents
1. [**Hydrological modeling**](#hydrological-modeling)
    1. [Watershed modeling and analysis](#watershed-modeling-and-analysis)
    2. [Stream modeling and analysis](#stream-modeling-and-analysis)
    3. [Flood modeling](#flood-modeling)
    4. [Flood animation](#flood-animation)

# Hydrological modeling
Start GRASS GIS in the `nc_spm_evolution` location
and create a new mapset called `hydrology`.

Set your region to our study area with 1 meter resolution
using the module
[g.region](https://grass.osgeo.org/grass72/manuals/g.region.html).
```
g.region region=region res=1
```

## Watershed modeling and analysis
Model flow accumulation for our study area using the module
[r.watershed](https://grass.osgeo.org/grass72/manuals/r.watershed.html).
Use the flag `-b` to beautify flat areas.
```
r.watershed elevation=elevation_2016 accumulation=accumulation -b
```

By default `r.watershed` uses multiple flow direction algorithm.
To compare multiple flow direction with single flow direction
rerun the module with and without the flag `-s`.
Be sure to set the `--overwrite` flag when rerunning the module.
```
r.watershed elevation=elevation_2016 accumulation=accumulation -s --overwrite
r.watershed elevation=elevation_2016 accumulation=accumulation --overwrite
```

Model basins or watersheds for our study area
using [r.watershed](https://grass.osgeo.org/grass72/manuals/r.watershed.html).
The `threshold` parameter determines minimum size of the basins.
Vary the threshold parameter
until you compute a basin capturing the entire gully.
```
r.watershed elevation=elevation_2016 threshold=100000 basin=watersheds
r.watershed elevation=elevation_2016 threshold=300000 basin=watersheds --overwrite
```

To create a vector map of the watershed containing the gully
first use bra to delete the other watersheds.
Query the watershed map to find the category value
for the cells containing the gully.
In this example the category was `4`.
The expression `if(watersheds == 4, 1, null())`
means if there are cells equal to 4 in the watershed raster map,
then write the value 1, else write null values.
Then convert the watershed raster to a vector with
[r.to.vect](https://grass.osgeo.org/grass72/manuals/r.to.vect.html)
and delete the rasters
with [g.remove](https://grass.osgeo.org/grass72/manuals/g.remove.html).
```
r.mapcalc "watershed = if(watersheds == 4, 1, null())"
r.to.vect -s input=watershed output=watershed type=area
g.remove -f type=raster name=watersheds,watershed
```

## Stream modeling and analysis
*Under development...*

## Flood modeling
There is a wetland in the low ground of this study landscape.
Model the wetland as a lake using the module
[r.lake](https://grass.osgeo.org/grass72/manuals/r.lake.html).
Set the water level to an elevation value
within the range of the study landscape,
ie. between 90 and 112 m.
In the seed tab use the ![pointer](images/grass-gui/pointer.png)
to pick coordinates near the lower right corner on the map display
for the starting point.
```
r.lake elevation=elevation_2016@PERMANENT water_level=91 lake=flood
```

## Flood animation
Install the `r.lake.series` add-on with
[g.extension](https://grass.osgeo.org/grass72/manuals/g.extension.html).
```
g.extension extension=r.lake.series
```

Create a time series of flood maps using the add-on module
[r.lake.series](https://grass.osgeo.org/grass72/manuals/addons/r.lake.series.html).
In the water tab
set the starting water level to 90 m, the end water level to 100 m,
and the water level step to 1 m.
Use the ![pointer](images/grass-gui/pointer.png)
to pick coordinates near the lower right corner on the map display
for the starting point.
In the time tab set the time step to 1 minute
to model flooding over a 10 minute period.
This module will create a time series of raster maps
named `flood_90.0`, `flood_91.0`, `flood_92.0`, etc...
that will all be registered in a space time raster dataset.
```
r.lake.series elevation=elevation_2016@PERMANENT output=flood start_water_level=90 end_water_level=100 water_level_step=1 coordinates=597636.035857,150588.067729 time_step=1
```

To animate this flooding time series launch the GRASS Animation Tool
[g.gui.animation](https://grass.osgeo.org/grass72/manuals/g.gui.animation.html).
If you launch the Animation Tool from the File menu in the GUI
follow the these instructions.
Create a new animation,
add a space-time dataset layer,
choose `space time raster dataset` as the input data type,
and choose the `flood` space time raster dataset.
Then add a raster map layer
and choose `elevation_2016`.
Move this raster map layer beneath the space time raster dataset.
Check the `Show raster legend` button
and choose `elevation_2016`
as the raster map in the d.legend dialog.
Press `Ok` to create to the animation.
Press `Play` to run the animation.
Export your animation as an animated gif.
Press the `Export` button,
select export to `animated GIF`,
then browse and name your file,
and press `Export`.
```
g.gui.animation strds=flood
```
