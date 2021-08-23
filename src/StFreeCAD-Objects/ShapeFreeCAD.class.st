Class {
	#name : #ShapeFreeCAD,
	#superclass : #ComplexGeoData,
	#instVars : [
		'area',
		'compSolids',
		'compounds',
		'edges',
		'faces',
		'orientation',
		'shapeType',
		'shells',
		'solids',
		'subShapes',
		'vertexes',
		'volume',
		'wires'
	],
	#category : #'StFreeCAD-Objects'
}

{ #category : #accessing }
ShapeFreeCAD >> faces [
	^faces
]
