Class {
	#name : #ComplexGeoData,
	#superclass : #Object,
	#instVars : [
		'boundBox',
		'matrix',
		'placement',
		'tag'
	],
	#category : #StFreeCAD
}

{ #category : #'as yet unclassified' }
ComplexGeoData >> aTest [
	^ self asString
]
