Class {
	#name : #ServerFreeCAD,
	#superclass : #Object,
	#instVars : [
		'connectionSocket',
		'isRunning',
		'isRunningLock',
		'interactionSocket',
		'receivedData'
	],
	#category : #StFreeCAD
}

{ #category : #initialization }
ServerFreeCAD >> initialize [ 
	super initialize .
	isRunningLock := Mutex new.
	self isRunning: false
]

{ #category : #interaction }
ServerFreeCAD >> interactOnConnection [
	interactionSocket := connectionSocket waitForAcceptFor: 1 ifTimedOut: [ ^self ].
	[ self interactUsing  ] fork
]

{ #category : #interaction }
ServerFreeCAD >> interactUsing [
	receivedData := interactionSocket receiveDataTimeout: 5.
	receivedData crTrace.
	"ensure: [ interactionSocket closeAndDestroy ]"
]

{ #category : #accessing }
ServerFreeCAD >> isRunning [ 
	^isRunningLock critical: [ isRunning ]
]

{ #category : #accessing }
ServerFreeCAD >> isRunning: aBoolean [
	isRunningLock critical: [ isRunning := aBoolean ]
]

{ #category : #receiving }
ServerFreeCAD >> receiveFromClient [
	receivedData := interactionSocket receiveDataTimeout: 5.
	receivedData crTrace.
	^isRunningLock critical: [ receivedData asString ]
]

{ #category : #sending }
ServerFreeCAD >> sendToClient: aString [ 
	interactionSocket sendData: aString.
]

{ #category : #communicating }
ServerFreeCAD >> sendToClientAndListen: aString [
	interactionSocket sendData: aString.
	receivedData := interactionSocket receiveDataTimeout: 5.
	receivedData crTrace.
	^isRunningLock critical: [ receivedData  ]
]

{ #category : #'interaction loop' }
ServerFreeCAD >> serve [
	[ [ self isRunning ]
		whileTrue: [self interactOnConnection ]]
		ensure: [ connectionSocket closeAndDestroy. interactionSocket closeAndDestroy]
]

{ #category : #accessing }
ServerFreeCAD >> start [ 
	isRunningLock critical: [ 
		self isRunning ifTrue: [^self].
		self isRunning: true].
	connectionSocket := Socket newTCP .
	connectionSocket listenOn: 65432 backlogSize: 5.
	[ self serve  ] fork 
]

{ #category : #'as yet unclassified' }
ServerFreeCAD >> stop [ 
	self isRunning: false
]
