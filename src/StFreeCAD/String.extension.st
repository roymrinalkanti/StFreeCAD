Extension { #name : #String }

{ #category : #'*StFreeCAD' }
String >> startProgram [
	| process |
	process := OSWSWinProcess new
		command: self;
		run.
	^process
]
