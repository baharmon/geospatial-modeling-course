## TODO
* Lidar reprojection
* Lidar in ArcGIS
* Create a new GRASS location




## REMOVED
Then patch both point clouds together using
[v.patch])(https://grass.osgeo.org/grass72/manuals/v.patch.html).
Delete the individual point clouds using
[g.remove](https://grass.osgeo.org/grass72/manuals/g.remove.html).
```
las2las --a_srs=EPSG:6543 --t_srs=EPSG:3358 -i J-08.las -o ncspm_J-08.las
v.in.lidar -r -t input=J-08_spm.las output=j_08 class_filter=2
v.patch input=i_08,j_08 output=points_2012
g.remove -f type=vector name=i_08,j_08
```
