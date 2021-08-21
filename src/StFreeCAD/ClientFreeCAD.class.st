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

{ #category : #activating }
ClientFreeCAD >> activateWorkbench: aString [
	self sendDataAndListen: ('Gui.activateWorkbench("{1}Workbench")' format: { aString })
]

{ #category : #Part }
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

{ #category : #accesing }
ClientFreeCAD >> edgesOf: aString [
	|list received|
	self sendDataAndListen: ('a=[]
obj =FreeCAD.ActiveDocument.getObjectsByLabel("{1}")[0]
edges=obj.Shape.Edges
for e in edges:
	edge=FreeCAD.ActiveDocument.addObject("Part::Feature","edge")
	edge.Shape=e
	a.append(edge.Label)
' format: {aString}).
	received := self retrieveValue: 'a'.
	list := OrderedCollection new.
	received regex: '\w+' matchesDo: [ :word| list add: word ].
	^list
]

{ #category : #'public access' }
ClientFreeCAD >> evaluate: aString [
	self sendDataAndListen: aString.
	
]

{ #category : #accesing }
ClientFreeCAD >> facesOf: aString [
	|list received|
	self sendDataAndListen: ('a=[]
obj =FreeCAD.ActiveDocument.getObjectsByLabel("{1}")[0]
faces=obj.Shape.Faces
for f in faces:
	face=FreeCAD.ActiveDocument.addObject("Part::Feature","face")
	face.Shape=f
	a.append(face.Label)
' format: {aString}).
	received := self retrieveValue: 'a'.
	list := OrderedCollection new.
	received regex: '\w+' matchesDo: [ :word| list add: word ].
	^list
]

{ #category : #accessing }
ClientFreeCAD >> getAllObjects [
	|list received|
	self sendDataAndListen: 'a=[]
for obj in FreeCAD.ActiveDocument.Objects:
	a.append(obj.Label)
'.
	received := self retrieveValue: 'a'.
	list := OrderedCollection new.
	received regex: '\w+' matchesDo: [ :word| list add: word ].
	^list
]

{ #category : #accessing }
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

{ #category : #accessing }
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

{ #category : #accessing }
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

{ #category : #accessing }
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

ip = "127.0.0.1"
port = 65432
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect((ip, port))

def returnValue(a):
	sock.sendall(a)


def closeSocket():
	sock.close()

'.
]

{ #category : #Part }
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

{ #category : #Part }
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
	self
		sendDataAndListen:
			'b = FreeCAD.ActiveDocument.addObject("Part::Box","box")
FreeCAD.ActiveDocument.recompute()
Gui.SendMsgToActiveView("ViewFit")'.
	^ self getObjectByLabel: (self retrieveValue: 'b.Label')
]

{ #category : #Part }
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
ClientFreeCAD >> makeCone [
	self
		sendDataAndListen:
			'c = FreeCAD.ActiveDocument.addObject("Part::Cone","cone")
FreeCAD.ActiveDocument.recompute()
Gui.SendMsgToActiveView("ViewFit")'.
	^ self getObjectByLabel: (self retrieveValue: 'c.Label')
]

{ #category : #Part }
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

{ #category : #opening }
ClientFreeCAD >> newDocument [
	self sendDataAndListen: 'doc= FreeCAD.newDocument()'
]

{ #category : #'instance creation' }
ClientFreeCAD >> openDocument: aString [ 
	self sendDataAndListen: ('doc= FreeCAD.open("{1}")' format: { aString })
]

{ #category : #receiving }
ClientFreeCAD >> retrieveValue: aString [ 
	|command receivedData|
	command:='returnValue(bytes(str(',aString,'),"utf-8"))'.
	self sendDataAndListen: command .
	receivedData:=server receiveFromClient crTrace.
	^receivedData .
]

{ #category : #'instance creation' }
ClientFreeCAD >> saveAsDocument: aString [
	self
		sendDataAndListen: ('doc= FreeCAD.saveAs("{1}")' format: {aString})
]

{ #category : #saving }
ClientFreeCAD >> saveDocument [
	self
		sendDataAndListen: ('doc=FreeCAD.ActiveDocument
doc.save()')
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

{ #category : #accesing }
ClientFreeCAD >> vertexesOf: aString [
	|list received|
	self sendDataAndListen: ('a=[]
obj =FreeCAD.ActiveDocument.getObjectsByLabel("{1}")[0]
vertexes=obj.Shape.Vertexes
for v in vertexes:
	vertex=FreeCAD.ActiveDocument.addObject("Part::Vertex","vertex")
	vertex.Shape=v
	a.append(vertex.Label)
' format: {aString}).
	received := self retrieveValue: 'a'.
	list := OrderedCollection new.
	received regex: '\w+' matchesDo: [ :word| list add: word ].
	^list
]

{ #category : #accesing }
ClientFreeCAD >> wiresOf: aString [
	|list received|
	self sendDataAndListen: ('a=[]
obj =FreeCAD.ActiveDocument.getObjectsByLabel("{1}")[0]
wires=obj.Shape.Wires
for w in wires:
	wire=FreeCAD.ActiveDocument.addObject("Part::Feature","wire")
	wire.Shape=w
	a.append(wire.Label)
' format: {aString}).
	received := self retrieveValue: 'a'.
	list := OrderedCollection new.
	received regex: '\w+' matchesDo: [ :word| list add: word ].
	^list
]
