
### Ground texture from landforms
Start GRASS GIS in the `nc_spm_evolution` location
and open the `terrain_analysis` mapset.
Set your region to our smaller, detailed study area
with 1 meter resolution
using the module
[g.region](https://grass.osgeo.org/grass72/manuals/g.region.html).
Specifying the saved region `subregion`.
```
g.region region=subregion res=1
```

Compute landform types uses the add-on module
[r.geomorphon](https://grass.osgeo.org/grass72/manuals/addons/r.geomorphon.html).
 ```
r.geomorphon elevation=elevation_2016 forms=forms search=24 skip=0 flat=1 dist=0
 ```
<p align="center">
  <img src="images/3d-ecosystems/landforms.png" height="250">
</p>

Use the raster map calculator
[r.mapcalc](https://grass.osgeo.org/grass72/manuals/r.mapcalc.html)
to create maps of similar landforms typologies.
Export these as GeoTIFFs using
[r.out.gdal](https://grass.osgeo.org/grass72/manuals/r.out.gdal.html).

```
r.mapcalc expression="valleys = if(forms@gully==9 ||| forms@gully==10,1,0)"
r.colors map=valleys@gully color=grey
```

*Under development...*
