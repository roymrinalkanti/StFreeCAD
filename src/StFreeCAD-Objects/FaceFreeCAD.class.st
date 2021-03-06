Class {
	#name : #FaceFreeCAD,
	#superclass : #ShapeFreeCAD,
	#instVars : [
		'centerOfMass',
		'mass',
		'matrixOfInertia',
		'OuterWire',
		'parameterRange',
		'principalProperties',
		'staticMoments',
		'surface',
		'tolerance',
		'wire'
	],
	#category : #'StFreeCAD-Objects'
}

{ #category : #accessing }
FaceFreeCAD >> surface [ 
	^surface
]
