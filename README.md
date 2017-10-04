[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)

# Geospatial modeling and fabrication

<p align="center"><img src="images/yosemite/yosemite_sq.png" height="500"></p>

This course is an introduction to digital design for landscape architects.
In this course you will develop a creative digital design process
seamlessly integrating research and design
using geographic information systems (GIS),
3D modeling and rendering, and
visual programming.
You will learn how to use geospatial data
to model and analyze landscapes
and visual programming to
parametrically model and transform new landforms.
You will learn how to model plants - from trees to grasses - in 3D,
automatically distribute them across your digital landscape,
and render photorealistic scenes.
Through a series of 3D modeling projects you will
design the restoration of a highly eroded landscape with a deep gully.
Each week you will spend a day in a workshop
learning new methods
and a day developing your projects.
You will work in small teams and present an exhibition of your
models and renderings at the end of the course.

**Assignments** [Projects](projects.md)

**Resources** [Geospatial data sources](geospatial-data-sources.md)

**Software** | [GRASS GIS](https://grass.osgeo.org) |
[Rhino](https://www.rhino3d.com/) |
[Blender](https://www.blender.org/)

**Tutorials** [Intro to GRASS GIS](http://ncsu-geoforall-lab.github.io/grass-intro-workshop/)

---
## Contents
1. [**Terrain modeling**](#terrain-modeling)
    1. [Elevation data sources](#elevation-data-sources)
    2. [Lidar](#lidar)
    3. [Topographic analysis](#topographic-analysis)
    4. [3D terrain visualization](#3d-terrain-visualization)
    4. [3D terrain modeling](#3d-terrain-modeling)
2. [**Hydrological modeling**](#hydrological-modeling)
    1. [Watershed modeling and analysis](#watershed-modeling-and-analysis)
    2. [Stream modeling and analysis](#stream-modeling-and-analysis)
    3. [Flood modeling](#flood-modeling)
    4. [Flood animation](#flood-animation)
3. [**Hydrological simulation**](#hydrological-simulation)
    1. [Shallow water flow](#shallow-water-flow)
    2. [Shallow water flow with landcover](#shallow-water-flow-with-landcover)
    3. [Erosion-deposition](#erosion-deposition)
    4. [Sediment flow](#sediment-flow)
    5. [Water flow animation](#water-flow-animation)
4. [**Parametric modeling**](#parametric-modeling)
    1. [Surface modeling](#surface-modeling)
    2. [Parametric surface modeling](#parametric-surface-modeling)
    3. [Attractors](#attractors)
5. [**3D ecosystems**](#3d-ecosystems)
    1. [Image classification](#image-classification)
    2. [3D planting](#3d-planting)
    3. [Particle systems](#particle-systems)
    4. [Rendering](#rendering)
    4. [Physics](#physics)
---

## Terrain modeling
In this section you will
process lidar data,
model the point cloud as a digital elevation model, and
analyze topographic parameters including
contours, slope, hillshading, and landforms.

### Elevation data sources
* [National Map Viewer](http://nationalmap.gov/viewer.html)
* [US Interagency Elevation Inventory](https://coast.noaa.gov/inventory/)
* [Open Topography](http://www.opentopography.org/)
* [NC Spatial Data Download](https://sdd.nc.gov/sdd/)

### Lidar
Start GRASS GIS in the `nc_spm_evolution` location
and create a new mapset called `lidar`.

<p align="center"><img src="images/grass-gui/grass_start.png" height="250"></p>
[Guide to starting GRASS GIS](https://grass.osgeo.org/grass72/manuals/helptext.html)

In the GRASS terminal
reproject the lidar data from NAD83 NC Survey Feet (EPSG 6543)
to NC State Plane Meters (EPSG 33580)
using the [liblas](https://www.liblas.org/) library.
```
las2las --a_srs=EPSG:6543 --t_srs=EPSG:3358 -i I-08.las -o ncspm_I-08.las
```

Set your region to our study area with 1 meter resolution
using the module
[g.region](https://grass.osgeo.org/grass72/manuals/g.region.html).
```
g.region n=151030 s=150580 w=597195 e=597645 save=region res=1
```

Import the lidar dataset as a raster digital surface model
using binning to convert points into a regular raster grid
with the module
[r.in.lidar](https://grass.osgeo.org/grass72/manuals/r.in.lidar.html).
Use the `mean` statistic and set the resolution to 5 meters.
Then import the lidar data as a bare earth digital elevation model
using `r.in.lidar` with the option `class_filter=2`
to filter for points in the ground class.
See the [ASPRS LAS Specification](http://www.asprs.org/wp-content/uploads/2010/12/LAS_1_4_r13.pdf)
for the definitive list of classes.
```
r.in.lidar input=ncspm_I-08.las output=binned_surface_2012 method=mean resolution=5
r.in.lidar input=ncspm_I-08.las output=binned_elevation_2012 method=mean resolution=5 class_filter=2
```

Create a raster map of vegetation by importing the lidar dataset
using binning with `r.in.lidar` at 2 meter resolution.
Filter the point cloud for low, medium, and high vegetation points
in classes 3, 4, and 5 using the option `class_filter=3,4,5`
and for the first return using the option `return_filter=first`.
Use the `max` statistic.
```
r.in.lidar input=ncspm_I-08.las output=vegetation_2012 method=max resolution=2 class_filter=3,4,5 return_filter=first
r.colors map=vegetation_2012 color=viridis
```

Import the lidar datasets as vector points using the module
[v.in.lidar](https://grass.osgeo.org/grass72/manuals/v.in.lidar.html).
Limit the import to the current region with flag `-r`.
Filter the point cloud for ground points in class 2
using the option `class_filter=2`.
Interpolate the point cloud
as a bare earth digital elevation model (DEM)
using the regularized spline with tension (RST) method
implemented as the module
[v.surf.rst](https://grass.osgeo.org/grass72/manuals/v.surf.rst.html).
```
v.in.lidar -r -t input=I-08_spm.las output=points_2012 class_filter=2
v.surf.rst input=points_2012 elevation=interpolated_elevation_2012 tension=10 smooth=1
```

See the
[lidar](https://grasswiki.osgeo.org/wiki/LIDAR)
guide on GRASS-Wiki for more information on lidar processing and analysis
in GRASS GIS.

### Topographic analysis
Start GRASS GIS in the `nc_spm_evolution` location
and create a new mapset called `terrain_analysis`.

Set your region to our study area with 1 meter resolution
using the module
[g.region](https://grass.osgeo.org/grass72/manuals/g.region.html)
by specifying the boundaries, a saved region, or a reference raster map.
```
g.region n=151030 s=150580 w=597195 e=597645 save=region res=1
g.region region=region res=1
g.region raster=elevation_2016 res=1
```

Compute contours from the digital elevation model using the module
[r.contour](https://grass.osgeo.org/grass72/manuals/r.contour.html)
with a 1 meter contour interval set with option `step=1`.
Then compute 5 meter contours using the option `step=5`.
Double click on the 5 meter contour map in the layer manager,
switch to the line tab,
and make the line weight heavier (eg. 2 or 3 px).
```
r.contour input=elevation_2016 output=contour_1m_2016 step=1
r.contour input=elevation_2016 output=contour_5m_2016 step=5
```

Compute a relief map for our study area's topography using the module
[r.relief](https://grass.osgeo.org/grass72/manuals/r.relief.html).
Optionally choose to vertically exaggerate the relief
with the parameter `zscale`.
You can also change the `altitude` or `azimuth` parameters
to explore different lighting conditions.
Then use [r.shade](https://grass.osgeo.org/grass72/manuals/r.shade.html)
to create a composite of elevation and relief maps
for the sake of visualization.
Adjust the brightness with the `brighten` parameter until it looks good.
```
r.relief input=elevation_2016 output=relief_2016 zscale=3
r.shade shade=relief_2016 color=elevation_2016 output=shaded_relief_2016 brighten=30
```
In the layer manager turn off all layers except
the shaded relief and the contours.
Move the contour maps above the shaded relief map.
Export the map as a .png file.

Compute the slope and aspect of our study area's topography
using the module
[r.slope.aspect](https://grass.osgeo.org/grass72/manuals/r.slope.aspect.html).
This module can calculate topographic parameters including
slope, aspect, tangential and profile curvature,
and partial derivatives from an elevation raster.
```
r.slope.aspect elevation=elevation_2016 slope=slope_2016 aspect=aspect_2016
```

Use the
![profile](images/grass-gui/layer-raster-profile.png)
GUI profile surface map button
to find the profile, i.e. section, of the digital elevation model.

Compare a time series of elevation maps using
map algebra with
[r.mapcalc](https://grass.osgeo.org/grass72/manuals/r.mapcalc.html)
and raster statistics with
[r.series](https://grass.osgeo.org/grass72/manuals/r.series.html).
Use `r.mapcalc` to calculate the difference in elevation,
ie. the net change in elevation, between 2004 and 2016.
Use [r.colors](https://grass.osgeo.org/grass72/manuals/r.colors.html)
to set an appropriate color table like the built-in `differences` color table
or a custom rules file like the `color_difference.txt`
included in the nc_spm_evolution location.
```
r.mapcalc "difference_2004_2016 = elevation_2016 - elevation_2004"
r.colors map=difference_2004_2016 color=differences
r.colors map=difference_2004_2016 rules=color_difference.txt
```

Calculate the range of the time series of elevation maps
using the module
[r.series](https://grass.osgeo.org/grass72/manuals/r.series.html).
```
r.series input=elevation2004,elevation_2012,elevation_2016 output=range_2004_2016 method=range
```

Identify the landforms in our study area using
a machine vision approach based on visibility
with the add-on module
[r.geomorphon](https://grass.osgeo.org/grass72/manuals/addons/r.geomorphon.html).
First call
[g.extension](https://grass.osgeo.org/grass72/manuals/g.extension.html)
to install the add-on.
Then run `r.geomorphon` to compute basic landforms.
Experiment with the
`search`, `skip`, and `flat` parameters.
```
g.extension extension=r.geomorphon
r.geomorphon elevation=elevation_2016 forms=forms_2016 search=12
```
The landform types are:
**1.** flat, **2.** summit, **3.** ridge, **4.** shoulder, **5.** spur,
**6.** slope, **7.** hollow, **8.** footslope, **9.** valley,
and **10.** depression.

<p align="center"><img src="images/geomorphon_legend.png"></p>

### 3D terrain visualization
Start GRASS GIS in the `nc_spm_evolution` location
and select the `terrain_analysis` mapset.

Set your region to our study area with 1 meter resolution
using the module
[g.region](https://grass.osgeo.org/grass72/manuals/g.region.html)
by specifying a reference raster map.
```
g.region raster=elevation_2016 res=1
```

Add the `elevation_2016` raster map layer to your map.

Change the map display mode from `2D` to `3D` view.
The map display will switch to 3D view
and the layer manager will switch to the `3D view` tab.
In the 3D view tab switch to `Data` tab.
Set the `Raster map` box to `elevation_2016`.
In the `Draw` box set `Fine mode: resolution` to `1`.
In the `Surface attributes` box set `Color` to
the elevation map `elevation_2016`,
the orthophoto `naip_2014`,
or another map of your choice.
This color map will be draped over the elevation surface.
In the `View` tab set `Z-exag` to `3`
to vertically exaggerate the elevation by a factor of 3.
In the `View` tab also
set the `Control view` to `SE`
and set the `Height` to `350`.
In the `Appearance` tab
expand the `Fringe` dropdown menu,
then in the `Edge with fringe` box check `S & E`
and in the `Settings` box set the
`elevation of the fringe from bottom` to `80`.
Experiment with different light source positions
in the `Lighting` menu in the `Appearance` tab.

Export your 3D view with the
`Save display to graphic file`
![export](images/grass-gui/map-export.png)
button.
<p align="center"><img src="images/3d-view.png"></p>

### 3D terrain modeling in Rhino
In this section you will export
a digital elevation model from GRASS GIS
and import it into Rhino for 3D modeling and visualization.

**Heightfield**
Start GRASS GIS in the `nc_spm_evolution` location
and select the `terrain_analysis` mapset.

Set your region to our study area with 3 meter resolution
using the module
[g.region](https://grass.osgeo.org/grass72/manuals/g.region.html)
by specifying a reference raster map.
```
g.region raster=elevation_2016 res=3
```

Convert the 2016 elevation raster map
from floating point values to integers
using the raster map calculator
[r.mapcalc](https://grass.osgeo.org/grass72/manuals/r.mapcalc.html).
```
r.mapcalc expression="integer_elevation_2016 = round(elevation_2016)"
```

Export `integer_elevation_2016` to `.png` with
[r.out.gdal](https://grass.osgeo.org/grass72/manuals/r.out.gdal.html).
```
r.out.gdal input=integer_elevation_2016@terrain_analysis output=elevation_2016.png format=PNG
```

Start Rhino5.

*Under development...*

**Point cloud patching**
```
g.region raster=elevation_2016 res=3
r.out.xyz input=elevation_2016 output=D:\rhino\elevation_3m.xyz separator=comma
```
*Under development...*

**RhinoTerrain**
```
g.region raster=elevation_2016 res=1
r.out.gdal input=elevation_2016 output=elevation_2016.tif format=GTiff
```
*Under development...*

## Hydrological modeling
Start GRASS GIS in the `nc_spm_evolution` location
and create a new mapset called `hydrology`.

Set your region to our study area with 1 meter resolution
using the module
[g.region](https://grass.osgeo.org/grass72/manuals/g.region.html).
```
g.region region=region res=1
```

### Watershed modeling and analysis
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

### Stream modeling and analysis
*Under development...*

### Flood modeling
Model a flood using the module
[r.lake](https://grass.osgeo.org/grass72/manuals/r.lake.html).
Set the water level to an elevation value
within the range of the study landscape,
ie. between 90 and 112 m.
In the seed tab use the ![pointer](images/grass-gui/pointer.png)
to pick coordinates near the lower right corner on the map display
for the starting point.
```
r.lake elevation=elevation_2016@PERMANENT water_level=98 lake=flood
```

### Flood animation
Install the `r.lake.series` add-on with
[g.extension](https://grass.osgeo.org/grass72/manuals/g.extension.html).
```
g.extension extension=r.lake.series
```

Create a time series of flood maps using the add-on module
[r.lake.series](https://grass.osgeo.org/grass72/manuals/addons/r.lake.series.html).
In the water tab
set the starting water level to 90 m, the end water level to 110 m,
and the water level step to 1 m.
Use the ![pointer](images/grass-gui/pointer.png)
to pick coordinates near the lower right corner on the map display
for the starting point.
In the time tab set the time step to 1 minute
to model flooding over a 20 minute period.
This module will create a time series of raster maps
named `flood_90.0`, `flood_91.0`, `flood_92.0`, etc...
that will all be registered in a space time raster dataset.
```
r.lake.series elevation=elevation_2016@PERMANENT output=flood start_water_level=90 end_water_level=110 water_level_step=1 coordinates=597636.035857,150588.067729 time_step=1
```

To animate this sea level rise time series launch the GRASS Animation Tool
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

## Hydrological simulation
In this section you will simulate overland water flow
and then the resulting erosion and deposition.

Start GRASS GIS in the `nc_spm_evolution` location
and select the `hydrology` mapset.

Set your region to our study area with 1 meter resolution
using the module
[g.region](https://grass.osgeo.org/grass72/manuals/g.region.html).
```
g.region region=region res=1
```

Compute the partial derivatives of the topography using the module
[r.slope.aspect](https://grass.osgeo.org/grass72/manuals/r.slope.aspect.html).
```
r.slope.aspect elevation=elevation_2016 dx=dx dy=dy
```

### Shallow water flow
Simulate shallow overland water flow with
[r.sim.water](https://grass.osgeo.org/grass72/manuals/r.sim.water.html).
for a 10 minute rain event
with a rainfall intensity of 50 mm/hr.
Walkers are the simulated particles of water in the computation.
Increasing the number of walkers reduces errors,
but increases computation time.
Start with a relatively low number of walkers like 10,000
and increase the number to 1,000,000 for your final simulation.
```
r.sim.water elevation=elevation_2016 dx=dx dy=dy rain_value=50.0 depth=depth nwalkers=10000 niterations=10
```

To see only the concentrated water flow
hide the cells with water depth less than value like `0.03` meters
by either
double clicking on the `depth` map in the layer manager
and setting the list of values to display to `100-0.03`
or running the command:
```
d.rast map=depth values=100-0.03
```
Experiment to find the right minimum value.

In the layer manager move the vector contour map above the depth map
and move the raster elevation or the shaded relief map below the depth map
to better visualize the relationship between topography and water.

Display the legend for the water depth map with either the
![legend](images/grass-gui/legend-add.png)
`Add raster legend` button
or
the command [d.legend](https://grass.osgeo.org/grass72/manuals/d.legend.html).
Optionally use the range parameter set to `range=100-0.03`
to show only the concentrated flow values.

### Shallow water flow with landcover
The first run of the simulation assumed constant landcover
with no infiltration and a constant surface roughness
with a default mannings n value of 0.1.
To study the landcover for our region
add the latest orthophotograph `naip_2014` and
the landcover, mannings, and infiltration maps
to your map display.
Display their legends with either the
![legend](images/grass-gui/legend-add.png)
`Add raster legend` button
or
the command [d.legend](https://grass.osgeo.org/grass72/manuals/d.legend.html).
Use the `-n` flag to hide categories
that are not represented in the data.
See the [Image classification](#image-classification) section
to learn how to derive these maps from orthophotography.

Now simulate overland water flow with
spatially variable surface roughness and infiltration.
Set `man=mannings` and `infil=infiltration`.
Make sure to set the `--overwrite` flag
because you are rerunning the simulation.
```
r.sim.water elevation=elevation_2016 dx=dx dy=dy rain_value=50.0 man=mannings infil=infiltration depth=depth nwalkers=10000 niterations=10 --overwrite
```

### Erosion-deposition
To simulate erosion-deposition you first need to compute
the detachment coefficient, transport coefficient, and shear stress.
Use map algebra with
[r.mapcalc](https://grass.osgeo.org/grass72/manuals/r.mapcalc.html)
to create new maps with constant values for these parameters.
```
r.mapcalc "detachment = 0.001"
r.mapcalc "transport = 0.001"
r.mapcalc "shear_stress = 0.0"
```

Simulate net erosion-deposition (kg/m^2^s) with
[r.sim.sediment](https://grass.osgeo.org/grass72/manuals/r.sim.sediment.html).
```
r.sim.sediment elevation=elevation_2016 water_depth=depth dx=dx dy=dy detachment_coeff=detachment transport_coeff=transport shear_stress=shear_stress man=mannings erosion_deposition=erosion_deposition nwalkers=10000
```
Display the legend for the erosion-deposition map with either the
![legend](images/grass-gui/legend-add.png)
`Add raster legend` button
or
the command [d.legend](https://grass.osgeo.org/grass72/manuals/d.legend.html).

### Sediment flow
In a detachment limited soil erosion regime
water can transport an infinite amount of sediment.
Therefore there is no deposition, only erosion.
In this regime erosion is only limited
by the water flow's capacity to detach sediment.

Overwrite the detachment and transport coefficients
with [r.mapcalc](https://grass.osgeo.org/grass72/manuals/r.mapcalc.html)
```
r.mapcalc "detachment = 0.0001" --overwrite
r.mapcalc "transport = 0.01" --overwrite
```

Simulate sediment flow (kg/ms)
in a detachment limited soil erosion regime with
[r.sim.sediment](https://grass.osgeo.org/grass72/manuals/r.sim.sediment.html).
```
r.sim.sediment elevation=elevation_2016 water_depth=depth dx=dx dy=dy detachment_coeff=detachment transport_coeff=transport shear_stress=shear_stress man=mannings sediment_flux=sediment_flux nwalkers=10000

```

### Water flow animation
To create a water flow animation first run the module
[r.sim.water](https://grass.osgeo.org/grass72/manuals/r.sim.water.html)
with the parameter `output_step=1` and the flag `-t` to
create a time series of water depth rasters.
With these settings this will output a water depth raster map
for each minute of the simulation labelled
`depth.01` through `depth.10`.
```
r.sim.water elevation=elevation_2016 dx=dx dy=dy rain_value=50.0 man=mannings infil=infiltration depth=depth nwalkers=10000 niterations=10 output_step=1 -t
```

List this time series of rasters with the module
[g.list](https://grass.osgeo.org/grass72/manuals/g.list.html).
Use the wildcard notation `*` to list all raster maps
with `depth.` in their names.
Use the flag `-m` to include the mapset names in the output.
Copy the list of maps from the output console.
```
g.list type=raster pattern=depth.* separator=comma -m
```

Launch the animation tool
[g.gui.animation](https://grass.osgeo.org/grass72/manuals/g.gui.animation.html)
and paste the list of depth maps into the raster parameter.
```
g.gui.animation raster=depth.01,depth.02,depth.03,depth.04,depth.05,depth.06,depth.07,depth.08,depth.09,depth.10
```

## License
Open educational materials licensed CC BY-SA 4.0 by Brendan Harmon :monkey_face:. The license does not apply to logos, fonts, linked material, quotations, or reprinted images by other authors, which may have different licenses. The fonts used in this repository are licensed under the SIL Open Font License by their authors. The syllabus is based on a latex template by Kieran Healy hosted at https://github.com/kjhealy/latex-custom-kjh.
