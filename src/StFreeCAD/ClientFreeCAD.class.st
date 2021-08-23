Class {
	#name : #ClientFreeCAD,
	#superclass : #Object,
	#instVars : [
		'serverAddress',
		'port',
		'server'
	],
	#category : #StFreeCAD
}

{ #category : #examples }
ClientFreeCAD class >> example2 [
	'D:\FreeCAD 0.19\bin\FreeCAD.exe' startProgram
]

{ #category : #examples }
ClientFreeCAD class >> example3 [
	| client box cone face2 boxShape |
	client := ClientFreeCAD new.
	client
		newDocument;
		activateWorkbench: #Part.
	client halt.
	box := client makeBox: {12 . 13 . 14}.
	cone := client makeCone.
	face2 := client getShape: #Face number: 2 ofObject: box.
	boxShape := client getShapeOfObject: box.
	{#Cut . #Common . #Section . #Fuse}
		do: [ :operation | client booleanOperation: operation on: box and: cone ].
	client stop
]

{ #category : #examples }
ClientFreeCAD class >> exampleParts [
	| client box cone face2 boxShape |
	client := ClientFreeCAD new.
	client
		newDocument;
		activateWorkbench: #Part.
	client halt.
	box := client makeBox: {12 . 13 . 14}.
	cone := client makeCone.
	face2 := client getShape: #Face number: 2 ofObject: box.
	boxShape := client getShapeOfObject: box.
	{#Cut . #Common . #Section . #Fuse}
		do: [ :operation | client booleanOperation: operation on: box and: cone ].
	client stop
]

{ #category : #examples }
ClientFreeCAD class >> exampleStartProgram [
	'D:\FreeCAD 0.19\bin\FreeCAD.exe' startProgram
]

{ #category : #activating }
ClientFreeCAD >> activateWorkbench: aString [
	| gui |
	gui := 'Gui' asP3GIdentifier.
	self
		evaluate: (gui => #activateWorkbench callWith: {(aString , 'Workbench')})
]

{ #category : #deprecated }
ClientFreeCAD >> booleanOperation: anOperation on: anObject and: anotherObject [
	"Cut Common Section Fuse"

	"not applicable on union (fusion) "

	self
		sendDataAndListen:
			('b = FreeCAD.ActiveDocument.addObject("Part::{1}","{1}")
FreeCAD.ActiveDocument.{1}.Base = FreeCAD.ActiveDocument.getObjectsByLabel("{2}")[0]
FreeCAD.ActiveDocument.{1}.Tool = FreeCAD.ActiveDocument.getObjectsByLabel("{3}")[0]
Gui.ActiveDocument.hide(FreeCAD.ActiveDocument.getObjectsByLabel("{2}")[0].Name)
Gui.ActiveDocument.hide(FreeCAD.ActiveDocument.getObjectsByLabel("{3}")[0].Name)
FreeCAD.ActiveDocument.recompute()
Gui.SendMsgToActiveView("ViewFit")'
				format:
					{anOperation.
					(anObject at: #Label).
					(anotherObject at: #Label)}).
	^ self getObjectByLabel: (self retrieveValue: 'b.Label')
]

{ #category : #deprecated }
ClientFreeCAD >> createEdgesOf: anObject [
	| list received |
	self
		sendDataAndListen:
			('a=[]
obj =FreeCAD.ActiveDocument.getObjectsByLabel("{1}")[0]
edges=obj.Shape.Edges
for e in edges:
	edge=FreeCAD.ActiveDocument.addObject("Part::Feature","edge")
	edge.Shape=e
	a.append(edge.Label)
' format: {anObject at: #Label}).
	received := self retrieveValue: 'a'.
	list := OrderedCollection new.
	received regex: '\w+' matchesDo: [ :word | list add: word ].
	^ list
]

{ #category : #deprecated }
ClientFreeCAD >> createFacesOf: anObject [
	| list received |
	self
		sendDataAndListen:
			('a=[]
obj =FreeCAD.ActiveDocument.getObjectsByLabel("{1}")[0]
faces=obj.Shape.Faces
for f in faces:
	face=FreeCAD.ActiveDocument.addObject("Part::Feature","face")
	face.Shape=f
	a.append(face.Label)
' format: {anObject at: #Label}).
	received := self retrieveValue: 'a'.
	list := OrderedCollection new.
	received regex: '\w+' matchesDo: [ :word | list add: word ].
	^ list
]

{ #category : #deprecated }
ClientFreeCAD >> createVertexesOf: anObject [
	| list received |
	self
		sendDataAndListen:
			('a=[]
obj =FreeCAD.ActiveDocument.getObjectsByLabel("{1}")[0]
vertexes=obj.Shape.Vertexes
for v in vertexes:
	vertex=FreeCAD.ActiveDocument.addObject("Part::Vertex","vertex")
	vertex.Shape=v
	a.append(vertex.Label)
' format: {anObject at: #Label}).
	received := self retrieveValue: 'a'.
	list := OrderedCollection new.
	received regex: '\w+' matchesDo: [ :word | list add: word ].
	^ list
]

{ #category : #deprecated }
ClientFreeCAD >> createWiresOf: anObject [
	| list received |
	self
		sendDataAndListen:
			('a=[]
obj =FreeCAD.ActiveDocument.getObjectsByLabel("{1}")[0]
wires=obj.Shape.Wires
for w in wires:
	wire=FreeCAD.ActiveDocument.addObject("Part::Feature","wire")
	wire.Shape=w
	a.append(wire.Label)
' format: {anObject at: #label}).
	received := self retrieveValue: 'a'.
	list := OrderedCollection new.
	received regex: '\w+' matchesDo: [ :word | list add: word ].
	^ list
]

{ #category : #Part }
ClientFreeCAD >> differenceOn: anObject and: anotherObject [
	"Cut Common Section Fuse"

	| instr activeDocument gui part |
	instr := P3GInstructionsList new.
	activeDocument := 'FreeCAD.ActiveDocument' asP3GIdentifier.
	part := 'part' asP3GIdentifier.
	gui := 'Gui' asP3GIdentifier.
	instr
		addAll:
			{(part
				<- (activeDocument => #addObject callWith: {'Part::Cut' . 'cut'})).
			(part => #Base <- anObject).
			(part => #Tool <- anotherObject).
			((activeDocument => #recompute) call).
			(gui => #SendMsgToActiveView callWith: {'ViewFit'})}.
	self evaluate: instr.
	^ ((activeDocument => (self return: part => #Name)) generate) asP3GIdentifier
]

{ #category : #'public access' }
ClientFreeCAD >> evaluate: anInstructionList [
	self sendDataAndListen: anInstructionList generate.
]

{ #category : #accessing }
ClientFreeCAD >> getAllObjects [
	| list received |
	self
		sendDataAndListen:
			'a=[]
for obj in FreeCAD.ActiveDocument.Objects:
	a.append(obj.Name)
'.
	received := self retrieveValue: 'a'.
	list := OrderedCollection new.
	received
		regex: '\w+'
		matchesDo: [ :word | list add: ('FreeCAD.ActiveDocument.',word) asP3GIdentifier ].
	^ list
]

{ #category : #deprecated }
ClientFreeCAD >> getObjectByLabel: aString [
	| dictString |
	self
		sendDataAndListen:
			('obj=FreeCAD.ActiveDocument.getObjectsByLabel("{1}")[0]'
				format: {aString asString}).
	self
		sendDataAndListen:
			'd={}
for i in obj.PropertiesList:
	d.update({i:str(obj.getPropertyByName(i))})
'.
	dictString := self
		retrieveValue: 'str(d).replace("\' , $' asString , '","\"")'.
	^ (NeoJSONReader on: dictString readStream)
		propertyNamesAsSymbols: true;
		next
]

{ #category : #deprecated }
ClientFreeCAD >> getSelectedObjects [
	|list received|
	self sendDataAndListen: 'a=[]
selectionObjs=Gui.Selection.getSelection()
for selectionObj in selectionObjs:
	a.append(selectionObj.Name)
'.
	received := self retrieveValue: 'a'.
	list := OrderedCollection new.
	received regex: '\w+' matchesDo: [ :word| list add: word ].
	^list
]

{ #category : #deprecated }
ClientFreeCAD >> getShape: aString number: anInteger ofObject: aDict [
	| shape |
	({'Edge' . 'Face' . 'Shell' . 'Solid' . 'Vertex' . 'Wire'}
		includes: aString)
		ifFalse: [ ^ self error: 'no shape of the type found' ].
	aString = 'Edge'
		ifTrue: [ shape := EdgeFreeCAD new ].
	aString = 'Face'
		ifTrue: [ shape := FaceFreeCAD new ].
	aString = 'Shell'
		ifTrue: [ shape := ShellFreeCAD new ].
	aString = 'Solid'
		ifTrue: [ shape := SolidFreeCAD new ].
	aString = 'Vertex'
		ifTrue: [ shape := VertexFreeCAD new ].
	aString = 'Wire'
		ifTrue: [ shape := WireFreeCAD new ].
	shape class allInstVarNames
		do: [ :instVarName | 
			shape
				instVarNamed: instVarName
				put:
					(self
						retrieveValue:
							('FreeCAD.ActiveDocument.getObjectsByLabel("{1}")[0].Shape.{2}{3}.{4}'
								format:
									{(aDict at: #Label).
									aString.
									anInteger.
									instVarName capitalized})) ].
	^ shape
]

{ #category : #deprecated }
ClientFreeCAD >> getShapeOfObject: aDict [
	| nEdges nFaces nVertexes nWires shape list |
	nEdges := (self
		retrieveValue:
			('FreeCAD.ActiveDocument.getObjectsByLabel("{1}")[0].Shape.{2}.__len__()'
				format:
					{(aDict at: #Label).
					#Edges})) asNumber.
	nFaces := (self
		retrieveValue:
			('FreeCAD.ActiveDocument.getObjectsByLabel("{1}")[0].Shape.{2}.__len__()'
				format:
					{(aDict at: #Label).
					#Faces})) asNumber.
	nVertexes := (self
		retrieveValue:
			('FreeCAD.ActiveDocument.getObjectsByLabel("{1}")[0].Shape.{2}.__len__()'
				format:
					{(aDict at: #Label).
					#Vertexes})) asNumber.
	nWires := (self
		retrieveValue:
			('FreeCAD.ActiveDocument.getObjectsByLabel("{1}")[0].Shape.{2}.__len__()'
				format:
					{(aDict at: #Label).
					#Wires})) asNumber.
	shape := ShapeFreeCAD new.
	shape class allInstVarNames
		do: [ :instVarName | 
			shape
				instVarNamed: instVarName
				put:
					(self
						retrieveValue:
							('FreeCAD.ActiveDocument.getObjectsByLabel("{1}")[0].Shape.{2}'
								format:
									{(aDict at: #Label).
									instVarName capitalized})) ].
	{(#Edges -> nEdges).
	(#Faces -> nFaces).
	(#Vertexs -> nVertexes).
	(#Wires -> nWires)}
		do: [ :eachShape | 
			list := OrderedCollection new.
			1 to: eachShape value do: [ :number | 
				list
					add:
						(self
							getShape: eachShape key allButLast
							number: number
							ofObject: aDict) ].
			eachShape key = #Vertexs
				ifFalse: [ shape instVarNamed: eachShape key uncapitalized put: list ]
				ifTrue: [ shape instVarNamed: #vertexes put: list ] ].
	^ shape
]

{ #category : #initialization }
ClientFreeCAD >> initialize [
	super initialize.
	serverAddress := 'localhost'.
	port := 54321.
	server := ServerFreeCAD new.
	server start.
	self
		sendDataAndListen:
			'import socket
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect(("127.0.0.1", 65432))
def returnValue(a):
	sock.sendall(a)


def closeSocket():
	sock.close()

'.
	{(#ActiveDocument -> 'FreeCAD.ActiveDocument').
	(#Gui -> 'Gui')}
		do:
			[ :each | Smalltalk globals at: each key put: each value asP3GIdentifier ]
]

{ #category : #Part }
ClientFreeCAD >> intersectionOn: anObject and: anotherObject [
	"Cut Common Section Fuse"

	| instr activeDocument gui part |
	instr := P3GInstructionsList new.
	activeDocument := 'FreeCAD.ActiveDocument' asP3GIdentifier.
	part := 'part' asP3GIdentifier.
	gui := 'Gui' asP3GIdentifier.
	instr
		addAll:
			{(part
				<- (activeDocument => #addObject callWith: {'Part::Common' . 'common'})).
			(part => #Base <- anObject ).
			(part => #Tool <- anotherObject).
			((activeDocument => #recompute) call).
			(gui => #SendMsgToActiveView callWith: {'ViewFit'})}.
	self evaluate: instr.
	^ ((activeDocument => (self return: part => #Name)) generate) asP3GIdentifier
]

{ #category : #deprecated }
ClientFreeCAD >> makeBottle [
	|makeBottle|
	makeBottle:='import Part, math
from FreeCAD import Base
myWidth=50
myHeight=70
myThickness=30
aPnt1=Base.Vector(-myWidth / 2., 0, 0)
aPnt2=Base.Vector(-myWidth / 2., -myThickness / 4., 0)
aPnt3=Base.Vector(0, -myThickness / 2., 0)
aPnt4=Base.Vector(myWidth / 2., -myThickness / 4., 0)
aPnt5=Base.Vector(myWidth / 2., 0, 0)
aArcOfCircle = Part.Arc(aPnt2, aPnt3, aPnt4)
aSegment1=Part.LineSegment(aPnt1, aPnt2)
aSegment2=Part.LineSegment(aPnt4, aPnt5)
aEdge1=aSegment1.toShape()
aEdge2=aArcOfCircle.toShape()
aEdge3=aSegment2.toShape()
aWire=Part.Wire([aEdge1, aEdge2, aEdge3])
aTrsf=Base.Matrix()
aTrsf.rotateZ(math.pi)
aMirroredWire=aWire.copy()
aMirroredWire.transformShape(aTrsf)
myWireProfile=Part.Wire([aWire, aMirroredWire])
myFaceProfile=Part.Face(myWireProfile)
aPrismVec=Base.Vector(0, 0, myHeight)
myBody=myFaceProfile.extrude(aPrismVec)
myBody=myBody.makeFillet(myThickness / 12.0, myBody.Edges)
neckLocation=Base.Vector(0, 0, myHeight)
neckNormal=Base.Vector(0, 0, 1)
myNeckRadius = myThickness / 4.
myNeckHeight = myHeight / 10.
myNeck = Part.makeCylinder(myNeckRadius, myNeckHeight, neckLocation, neckNormal)
myBody = myBody.fuse(myNeck)
Part.show(myBody)'.
	
	self sendDataAndListen: makeBottle.
]

{ #category : #deprecated }
ClientFreeCAD >> makeBottle: anOrderedCollection [
	|makeBottle|
	makeBottle:='import Part, math
from FreeCAD import Base
myWidth={1}
myHeight={2}
myThickness={3}
aPnt1=Base.Vector(-myWidth / 2., 0, 0)
aPnt2=Base.Vector(-myWidth / 2., -myThickness / 4., 0)
aPnt3=Base.Vector(0, -myThickness / 2., 0)
aPnt4=Base.Vector(myWidth / 2., -myThickness / 4., 0)
aPnt5=Base.Vector(myWidth / 2., 0, 0)
aArcOfCircle = Part.Arc(aPnt2, aPnt3, aPnt4)
aSegment1=Part.LineSegment(aPnt1, aPnt2)
aSegment2=Part.LineSegment(aPnt4, aPnt5)
aEdge1=aSegment1.toShape()
aEdge2=aArcOfCircle.toShape()
aEdge3=aSegment2.toShape()
aWire=Part.Wire([aEdge1, aEdge2, aEdge3])
aTrsf=Base.Matrix()
aTrsf.rotateZ(math.pi)
aMirroredWire=aWire.copy()
aMirroredWire.transformShape(aTrsf)
myWireProfile=Part.Wire([aWire, aMirroredWire])
myFaceProfile=Part.Face(myWireProfile)
aPrismVec=Base.Vector(0, 0, myHeight)
myBody=myFaceProfile.extrude(aPrismVec)
myBody=myBody.makeFillet(myThickness / 12.0, myBody.Edges)
neckLocation=Base.Vector(0, 0, myHeight)
neckNormal=Base.Vector(0, 0, 1)
myNeckRadius = myThickness / 4.
myNeckHeight = myHeight / 10.
myNeck = Part.makeCylinder(myNeckRadius, myNeckHeight, neckLocation, neckNormal)
myBody = myBody.fuse(myNeck)
Part.show(myBody)' format: { anOrderedCollection at: 1. anOrderedCollection at: 2. anOrderedCollection at: 3 }.
	
	self sendDataAndListen: makeBottle.
]

{ #category : #Part }
ClientFreeCAD >> makeBox [
	| instr activeDocument gui part |
	instr := P3GInstructionsList new.
	activeDocument := 'FreeCAD.ActiveDocument' asP3GIdentifier.
	part := 'part' asP3GIdentifier.
	gui := 'Gui' asP3GIdentifier.
	instr
		addAll:
			{(part
				<- (activeDocument => #addObject callWith: {'Part::Box' . 'box'})).
			((activeDocument => #recompute) call).
			(gui => #SendMsgToActiveView callWith: {'ViewFit'})}.
	self evaluate: instr.
	^ ((activeDocument => (self return: part => #Name)) generate) asP3GIdentifier
]

{ #category : #deprecated }
ClientFreeCAD >> makeBox: aVector [
	self
		sendDataAndListen:
			('b = FreeCAD.ActiveDocument.addObject("Part::Box","box")
b.Length={1}
b.Width={2}
b.Height={3}
FreeCAD.ActiveDocument.recompute()
Gui.SendMsgToActiveView("ViewFit")'
				format:
					{(aVector at: 1).
					(aVector at: 2).
					(aVector at: 3)}).
	^ self getObjectByLabel: (self retrieveValue: 'b.Label')
]

{ #category : #Part }
ClientFreeCAD >> makeBoxL: length W: width H: height [
	| instr activeDocument gui part |
	instr := P3GInstructionsList new.
	activeDocument := 'FreeCAD.ActiveDocument' asP3GIdentifier.
	part := 'part' asP3GIdentifier.
	gui := 'Gui' asP3GIdentifier.
	instr
		addAll:
			{(part
				<- (activeDocument => #addObject callWith: {'Part::Box' . 'box'})).
			(part => #Length <- length).
			(part => #Width <- width).
			(part => #Height <- height).
			((activeDocument => #recompute) call).
			(gui => #SendMsgToActiveView callWith: {'ViewFit'})}.
	self evaluate: instr.
	^ ((activeDocument => (self return: part => #Name)) generate) asP3GIdentifier
]

{ #category : #Part }
ClientFreeCAD >> makeCone [
	| instr activeDocument gui part |
	instr := P3GInstructionsList new.
	activeDocument := 'FreeCAD.ActiveDocument' asP3GIdentifier.
	part := 'part' asP3GIdentifier.
	gui := 'Gui' asP3GIdentifier.
	instr
		addAll:
			{(part
				<- (activeDocument => #addObject callWith: {'Part::Cone' . 'cone'})).
			((activeDocument => #recompute) call).
			(gui => #SendMsgToActiveView callWith: {'ViewFit'})}.
	self evaluate: instr.
	^ ((activeDocument => (self return: part => #Name)) generate) asP3GIdentifier
]

{ #category : #deprecated }
ClientFreeCAD >> makeCone: anArray [
	self
		sendDataAndListen:
			('c = FreeCAD.ActiveDocument.addObject("Part::Cone","cone")
c.Radius1={1}
c.Radius2={2}
c.Height={3}
c.Angle={4}
FreeCAD.ActiveDocument.recompute()
Gui.SendMsgToActiveView("ViewFit")'
				format:
					{(anArray at: 1).
					(anArray at: 2).
					(anArray at: 3).
					(anArray at: 4)}).
	^ self getObjectByLabel: (self retrieveValue: 'b.Label')
]

{ #category : #Part }
ClientFreeCAD >> makeConeR1: radius1 R2: radius2 H: height A: angle [
	| instr activeDocument gui part |
	instr := P3GInstructionsList new.
	activeDocument := 'FreeCAD.ActiveDocument' asP3GIdentifier.
	part := 'part' asP3GIdentifier.
	gui := 'Gui' asP3GIdentifier.
	instr
		addAll:
			{(part
				<-
					(activeDocument => #addObject
						callWith: {'Part::Cone' . 'cone'})).
			(part => #Radius1 <- radius1).
			(part => #Radius2 <- radius2).
			(part => #Height <- height).
			(part => #Angle <- angle).
			((activeDocument => #recompute) call).
			(gui => #SendMsgToActiveView callWith: {'ViewFit'})}.
	self evaluate: instr.
	^ ((activeDocument => (self return: part => #Name)) generate) asP3GIdentifier
]

{ #category : #opening }
ClientFreeCAD >> newDocument [
	| doc freecad |
	doc := 'doc' asP3GIdentifier.
	freecad := 'FreeCAD' asP3GIdentifier.
	self evaluate: doc <- ((freecad => #newDocument) call).
	^ doc
]

{ #category : #'instance creation' }
ClientFreeCAD >> openDocument: aString [
	| doc app |
	doc := 'doc' asP3GIdentifier.
	app := 'App' asP3GIdentifier.
	self evaluate: doc <- ((app => #open) callWith: {aString}).
	^ doc
]

{ #category : #Part }
ClientFreeCAD >> position: position object: anObject [
	"Use FreeCAD Vector to generate vectors for position"

	| instr activeDocument |
	instr := P3GInstructionsList new.
	activeDocument := 'FreeCAD.ActiveDocument' asP3GIdentifier.
	instr
		addAll: {(anObject => #Placement => #Base <- position)}.
	self evaluate: instr
]

{ #category : #receiving }
ClientFreeCAD >> retrieveValue: aString [ 
	|command receivedData|
	command:='returnValue(bytes(str(',aString,'),"utf-8"))'.
	self sendDataAndListen: command .
	receivedData:=server receiveFromClient crTrace.
	^receivedData .
]

{ #category : #accessing }
ClientFreeCAD >> return: aP3GAttributeReference [
	^self retrieveValue: aP3GAttributeReference generate
]

{ #category : #Part }
ClientFreeCAD >> rotate: rotation object: anObject [
	| instr activeDocument |
	instr := P3GInstructionsList new.
	activeDocument := 'FreeCAD.ActiveDocument' asP3GIdentifier.
	instr
		addAll: {(anObject => #Placement => #Rotation <- rotation)}.
	self evaluate: instr
]

{ #category : #deprecated }
ClientFreeCAD >> rotationAxis: axis angle: angle object: anObject [
	self
		sendDataAndListen:
			('position=FreeCAD.ActiveDocument.getObjectsByLabel("{1}")[0].Placement.Base
FreeCAD.ActiveDocument.getObjectsByLabel("{1}")[0].Placement = App.Placement(position,App.Vector({2},{3},{4}),{5})'
				format:
					{(anObject at: #Label).
					(axis at: 1).
					(axis at: 2).
					(axis at: 3). angle})
]

{ #category : #'instance creation' }
ClientFreeCAD >> saveAsDocument: aString [
	| doc activeDocument |
	doc := 'doc' asP3GIdentifier.
	activeDocument := 'FreeCAD.ActiveDocument' asP3GIdentifier.
	self evaluate: doc <- (activeDocument => #saveAs callWith: {aString}).
	^doc
]

{ #category : #saving }
ClientFreeCAD >> saveDocument [
	| doc activeDocument |
	doc := 'doc' asP3GIdentifier.
	activeDocument := 'FreeCAD.ActiveDocument' asP3GIdentifier.
	self evaluate: doc <- ((activeDocument => #save) call).
	^ doc
]

{ #category : #Part }
ClientFreeCAD >> sectionOn: anObject and: anotherObject [
	"Cut Common Section Fuse"

	| instr activeDocument gui part |
	instr := P3GInstructionsList new.
	activeDocument := 'FreeCAD.ActiveDocument' asP3GIdentifier.
	part := 'part' asP3GIdentifier.
	gui := 'Gui' asP3GIdentifier.
	instr
		addAll:
			{(part
				<- (activeDocument => #addObject callWith: {'Part::Section' . 'section'})).
			(part => #Base <- anObject).
			(part => #Tool <- anotherObject).
			((activeDocument => #recompute) call).
			(gui => #SendMsgToActiveView callWith: {'ViewFit'})}.
	self evaluate: instr.
	^ ((activeDocument => (self return: part => #Name)) generate) asP3GIdentifier
]

{ #category : #sending }
ClientFreeCAD >> sendDataAndListen: aString [ 
	|stream receivedData|
	stream := SocketStream openConnectionToHostNamed: serverAddress  port: port.
	stream sendCommand: aString .
	receivedData := stream upToEnd crTrace.
	stream close.
	^receivedData
]

{ #category : #closing }
ClientFreeCAD >> stop [
	server stop.
]

{ #category : #Part }
ClientFreeCAD >> unionOn: anObject and: anotherObject [
	"Cut Common Section Fuse"

	| instr activeDocument gui part |
	instr := P3GInstructionsList new.
	activeDocument := 'FreeCAD.ActiveDocument' asP3GIdentifier.
	part := 'part' asP3GIdentifier.
	gui := 'Gui' asP3GIdentifier.
	instr
		addAll:
			{(part
				<- (activeDocument => #addObject callWith: {'Part::Fuse' . 'fuse'})).
			(part => #Base <- anObject).
			(part => #Tool <- anotherObject).
			((activeDocument => #recompute) call).
			(gui => #SendMsgToActiveView callWith: {'ViewFit'})}.
	self evaluate: instr.
	^ ((activeDocument => (self return: part => #Name)) generate) asP3GIdentifier
]
