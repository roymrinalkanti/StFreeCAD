# StFreeCAD
A package to create and edit parametric 3D models in FreeCAD from Pharo. This project is a part of GSoC 2021 https://summerofcode.withgoogle.com/dashboard/project/4824667119943680/overview/.
It uses sockets to communicate with FreeCAD python interpreter. Commands are sent to it in the form of python strings generated using Python3Generator: https://github.com/juliendelplanque/Python3Generator.

## Installation
To run the package, you need to have FreeCAD installed on your computer. If not installed, download and install via the link: https://www.freecadweb.org/downloads.php .
### FreeCAD side
Once FreeCAD is installed, you need to install the external workbench given in this repository to your FreeCAD. To proceed, download the repository and extract the folder named **StFreeCADSide** on your local hard disk.
Further instructions vary for different Operating Systems. The following link describes the installation https://wiki.freecadweb.org/How_to_install_additional_workbenches. Follow *Manual Installation* steps for your appropriate OS.

#### For Windows:
- Within FreeCAD, locate the macro path by choosing Edit → Preferences → General → Macro and look for the ”Macro path”
- Supposed your Windows-Login is “username” the default macro path is %APPDATA%\FreeCAD\ which is usually C:\Users\username\Appdata\Roaming\FreeCAD
- Within the macro-directory create (if not already present) a folder called “Mod”
- Within the Mod folder, create a folder with the name of the workbench, for example “Curves”
- Now move the unpacked files and sub-folders of the workbench to the just created workbench-folder.
### Pharo side
To install this project in your Pharo image, open a playground and *DoIt* the following code snippet:
```
Metacello new
    baseline: 'StFreeCAD';
    repository: 'github://roymrinalkanti/StFreeCAD:main/src';
    load
```

## How to begin using StFreeCAD

1. Load the image with the package installed.
2. Start FreeCAD and wait for the welcome page to load.
3. On Pharo, run the following code to establish connection with FreeCAD.
```
client := ClientFreeCAD new.
```
4. To cease communication between Pharo and FreeCAD, pass the message *stop* to the *ClientFreeCAD* object:
```
client stop.
```
## Example
```
client := ClientFreeCAD new.

client newDocument; activateWorkbench: #Part.

box := client makeBoxL: 12 W: 13 H: 14.
box2 := client makeBox.
cone := client makeCone.
cone2 := client makeConeR1: 10 R2: 20  H: 10  A: 270. 

position:=FreeCAD vectorX: 3 Y: 4 Z: 5.
client position: position object: box.

rotation := FreeCAD rotationAxis: position angle: 45.
client rotate: rotation object: cone.

inter:=client differenceOn: box and: cone. 

allObjs :=client getAllObjects .

client return: (box=>#Shape=>#Edges=>#__len__) call.

client saveDocument 

client saveAsDocument: 'D:/test2.FCStd'.

client openDocument: 'D:/eh.FCStd'.

client return: cone=>#Placement.

client stop.
```
