Class {
	#name : #FreeCAD,
	#superclass : #Object,
	#category : #StFreeCAD
}

{ #category : #'as yet unclassified' }
FreeCAD class >> rotationAxis: aVector angle: anAngle [
	| app |
	app := 'App' asP3GIdentifier .
	^ (app => #Rotation callWith: { aVector . anAngle  })
]

{ #category : #'as yet unclassified' }
FreeCAD class >> vectorX: x Y: y Z: z [
	^('App.Vector({1},{2},{3})' format: { x. y. z }) asP3GIdentifier .
]
