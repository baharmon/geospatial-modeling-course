[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)

# Geospatial modeling and fabrication

<p align="center"><img src="images/yosemite_sq.png" height="500"></p>

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

**Software** | [GRASS GIS](https://grass.osgeo.org) |
[Rhino](https://www.rhino3d.com/) |
[Blender](https://www.blender.org/)

**Tutorials** [Intro to GRASS GIS](http://ncsu-geoforall-lab.github.io/grass-intro-workshop/)

**Resources** [Geospatial data sources](geospatial-data-sources.md)

---
## Contents
2. [**Terrain modeling**](#terrain-modeling)
    1. [Elevation data sources](#elevation-data-sources)
    2. [Lidar in GRASS GIS](#lidar-in-grass-gis)
    3. [Topographic analysis in GRASS GIS](#topographic-analysis-in-grass-gis)
    4. [3D terrain modeling in Rhino](#3d-terrain-modeling-in-rhino)
2. [**Hydrological modeling**](#hydrological-modeling)
3. [**Geospatial simulation**](#geospatial-simulation)
3. [**Image classification**](#image-classification)
---

## Elevation data sources
* [National Map Viewer](http://nationalmap.gov/viewer.html)
* [US Interagency Elevation Inventory](https://coast.noaa.gov/inventory/)
* [Open Topography](http://www.opentopography.org/)
* [NC Spatial Data Download](https://sdd.nc.gov/sdd/)

## Terrain modeling
In this section you will process lidar data,
model the point cloud as a digital elevation model, and
analyze topographic parameters including
contours, slope, hillshading, and landforms.

### Lidar in GRASS GIS
Start GRASS GIS in the `nc_spm_evolution` location
and create a new mapset called `lidar`.

<p align="center"><img src="images/grass_start.png" height="250"></p>

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

### Topographic analysis in GRASS GIS
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

Use either the
![profile](images/grass-gui/layer-raster-profile.png)
GUI profile surface map button,
[d.profile](https://grass.osgeo.org/grass72/manuals/d.profile.html), or
[r.profile](https://grass.osgeo.org/grass72/manuals/r.profile.html)
to find the profile, i.e. section, of the digital elevation model.
```
r.profile -i input=elevation_2016 output=- null=*
```

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

Calculate the average and range of the time series of elevation maps
using the module
[r.series](https://grass.osgeo.org/grass72/manuals/r.series.html).
```
r.series input=elevation2004,elevation_2012,elevation_2016 output=average_2004_2016,range_2004_2016 method=average,range
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

### 3D terrain modeling in Rhino

## Hydrological modeling

## Geospatial simulation

## License
Open educational materials licensed CC BY-SA 4.0 by Brendan Harmon :monkey_face:. The license does not apply to logos, fonts, linked material, quotations, or reprinted images by other authors, which may have different licenses. The fonts used in this repository are licensed under the SIL Open Font License by their authors. The syllabus is based on a latex template by Kieran Healy hosted at https://github.com/kjhealy/latex-custom-kjh.
