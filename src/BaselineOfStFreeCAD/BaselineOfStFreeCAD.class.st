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
				package: 'StFreeCAD'
					with: [ spec requires: #('NeoJSON' 'OSWinSubprocess' 'Python3Generator') ];
				package: 'StFreeCAD-Objects'
					with: [ spec requires: #('StFreeCAD' 'NeoJSON' 'OSWinSubprocess' 'Python3Generator') ];
				baseline: 'NeoJSON'
					with: [ spec repository: 'github://svenvc/NeoJSON/repository' ];
				baseline: 'Python3Generator'
					with: [ spec repository: 'github://juliendelplanque/Python3Generator/src' ];
				baseline: 'OSWinSubprocess'
					with: [ spec
						repository: 'github://pharo-contributions/OSWinSubprocess:master/repository' ] ]
]
