Class {
	#name : #BaselineOfStFreeCAD,
	#superclass : #BaselineOf,
	#category : #BaselineOfStFreeCAD
}

{ #category : #baselines }
BaselineOfStFreeCAD >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ "Packages"
			spec
				package: 'StFreeCAD' with: [ spec requires: #('NeoJSON' 'OSWinSubprocess') ];
				baseline: 'NeoJSON'
					with: [ spec repository: 'github://svenvc/NeoJSON/repository' ];
				baseline: 'OSWinSubprocess'
					with: [ spec repository: 'github://pharo-contributions/OSWinSubprocess:master/repository' ] ]
]
