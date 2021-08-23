# StFreeCAD
A package to create and edit parametric 3D models in FreeCAD from Pharo.

## Installation
To run the package, you need to have FreeCAD installed on your computer. If not installed, download and install via the link: https://www.freecadweb.org/downloads.php .
### FreeCAD side

### Pharo side
To install this project in your Pharo image, open a playground and *DoIt* the following code snippet:
```
Metacello new
    baseline: 'StFreeCAD';
    repository: 'github://roymrinalkanti/StFreeCAD:main/src';
    load
```

