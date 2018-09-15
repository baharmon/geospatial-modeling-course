# Contents
1. [**3D planting**](#3d-planting)
    1. [Import tree](#import-tree)
    2. [Leaf material](#leaf-material)
    3. [Bark material](#bark-material)
    4. [Environment](#environment)

# 3D planting
This section describes how to setup [Xfrog](xfrog.com/) 3D trees for
Blender's Cycles renderer.
Xfrog is software for procedurally generating 3D plants.
We will use libraries of 3D trees, shrubs, and grasses created in Xfrog
to model the ecosystem of our study landscape.
The following steps detail how to setup an Eastern White Pine
and should be adapted accordingly for other plants.
The instructions for this section are also available as a
[spreadsheet](https://docs.google.com/spreadsheets/d/1hc24iUS0iS9Jv8Kwcr09twPLLuGAd1R4tEw8rD2qJPA/edit?usp=sharing).

## Import tree
First, check your settings.
Open `System settings` by hotkey (Ctl + Alt + U)
or through the menu `File > User Preferences > System`.
Uncheck `Mipmaps`.
Set `Clip alpha` to 0.
Turn off `Anisotropic Filtering`.
Depending on your hardware, select a
`Cycles Compute Device`
such as CUDA for NVDIA GPUs.
Be sure to `Save User Settings`!

Set up a new scene in Blender for preparing an [Xfrog](xfrog.com/) 3D tree.
Delete the cube.
Then set the render engine to `Cycles Render`.
Optionally highlight the lamp in the Outliner,
then in the Data tab, change Lamp from Point to Sun,
and then in the World tab, check Blend Sky.

Next import the 3D tree.
With `File > Import > Wavefront (.obj)`
import `\XfrogPlants\XfrogPlants_USA_East_OBJ\Models\EA12_Pinus strobus_Eastern_White_Pine\EA12a.obj`.
Then highlight `EA12a` in the Outliner.
Rename `EA12a` to `Eastern White Pine A`.
In the Object tab, change Rotation parameter X from 90d to 0.
Optionally adjust the 3D view settings by pressing `n` to open the side panel,
expanding the Display menu, and unchecking Outline Selected.
Press `r` for Rendered viewport shading.

## Leaf material
Set up the leaf materials for the tree.
In the Outliner, expand Eastern White Pine A, expand EA12a, and select Needle.
In the Material tab, select Leaf,
then under Surface click the `Use Nodes` button.
Open the Node Editor.
In the Node Editor
there will be a `Diffuse BSDF` connected to `Material Output`.
Add a `Mix Shader`.
Connect Diffuse BSDF's BSDF output to Mix Shader's 2nd Shader input.
Connect Mix Shader's Shader output to Material Ouput's Surface input.
Add a `Transparent BSDF`.
Connect Transparent BSDF's BSDF output to Mix Shader's 1st Shader input.
Add an `Image Texture`.
In Image Texture open the leaf's image file `EA12ned.tif`.
Connect Image Texture's Color output to Diffuse BSDF's Color input.
Connect Image Texture's Alpha output to Mix Shader's Factor (Fac) input.

## Bark material
Now setup the bark materials for the tree.
In the Outliner, expand Eastern White Pine A, expand EA12a, and select Bark.
In the Material tab, select Bark,
then under Surface click the `Use Nodes` button.
Open the Node Editor.
In the Node Editor
there will be a `Diffuse BSDF` connected to `Material Output`.
Add an `Image Texture`.
In Image Texture open the bark's image file `EA12brk.tif`.
Connect Image Texture's Color output to Diffuse BSDF's Color input.
Add an `Image Texture`.
In Image Texture open the bark's bump map image file `EA12brk_b.tif`.
Add a `Bump`.
Connect Image Texture's Color output to Bump's Height input.
Connect Bump's Normal output to Diffuse BSDF's Normal input.
Optionally set Bump's strength to 2 or higher.

## Environment
Optionally setup the world environment.
In the World tab click the `Use Nodes` button.
Set Color to `Sky Texture`.
Select `Hosek / Wilkie` or `Preetham`.
Check `Ambient Occlusion` and set to 0.5.

To save your 3D tree, first store the linked files
such as the `.obj` and the `.tif`s
with `External Data > Pack all into .blend`.
Then `Select All`  (A), group (Crtl+G), and
assign the group a name such as `Eastern White Pine A`.
Save as (Shift+Ctrl+S) `c_eastern_white_pine_a.blend`.
