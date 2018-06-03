# Contents
1. [**Erosion modeling**](#erosion-modeling)
    1. [RULSE](#rusle)
    2. [USPED](#usped)
    3. [Shallow water flow](#shallow-water-flow)
    4. [Shallow water flow with landcover](#shallow-water-flow-with-landcover)
    5. [Erosion-deposition](#erosion-deposition)
    6. [Sediment flow](#sediment-flow)
    7. [Water flow animation](#water-flow-animation)

# Erosion modeling
In this section you will learn about
the RUSLE, USPED, and SIMWE erosion models.
You will use SIMWE to simulate overland water flow
and then the resulting erosion and deposition.

Start GRASS GIS in the `nc_spm_evolution` location
and select the `erosion` mapset.

Set your region to our study area with 1 meter resolution
using the module
[g.region](https://grass.osgeo.org/grass72/manuals/g.region.html).
```
g.region region=region res=1
```

## RUSLE
*Under development*

## USPED
*Under development*

## Shallow water flow
Compute the partial derivatives of the topography using the module
[r.slope.aspect](https://grass.osgeo.org/grass72/manuals/r.slope.aspect.html).
```
r.slope.aspect elevation=elevation_2016 dx=dx dy=dy
```

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

## Shallow water flow with landcover
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

## Erosion-deposition
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

## Sediment flow
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

## Water flow animation
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
