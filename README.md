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

Set your region to our study area with 1 meter resolution
using the module`g.region`.
```
g.region n=151030 s=150580 w=597195 e=597645 save=region res=1
```

Import the lidar dataset as a raster using binning
with the module `r.in.lidar`.  
```
r.in.lidar
```

Import the lidar datasets as vector points
using the module `v.in.lidar`.
Limit the import to the current region with flag `r`.
Filter the point clouds for ground points in class 2
using the option `class_fitler=2`. 
See the [ASPRS LAS Specification](http://www.asprs.org/wp-content/uploads/2010/12/LAS_1_4_r13.pdf)
for a definitive list of classes.
Then patch both point clouds together using the module `v.patch`.
Delete the individual point clouds using `g.remove`.
Interpolate the patched point cloud
as a bare earth digital elevation model (DEM)
using the regularized spline with tension (RST) algorithm
implemented as the module `v.surf.rst`.

```
v.in.lidar -r -t input=I-08_spm.las output=i_08 class_filter=2
v.in.lidar -r -t input=J-08_spm.las output=j_08 class_filter=2
v.patch input=i_08,j_08 output=points_2012
g.remove -f type=vector name=i_08,j_08
v.surf.rst input=points_2012 elevation=elevation_2012 tension=10 smooth=1
```

### Topographic analysis in GRASS GIS
```
g.region
```

### 3D terrain modeling in Rhino

## Hydrological modeling

## Geospatial simulation

## License
Open educational materials licensed CC BY-SA 4.0 by Brendan Harmon :monkey_face:. The license does not apply to logos, fonts, linked material, quotations, or reprinted images by other authors, which may have different licenses. The fonts used in this repository are licensed under the SIL Open Font License by their authors. The syllabus is based on a latex template by Kieran Healy hosted at https://github.com/kjhealy/latex-custom-kjh.
