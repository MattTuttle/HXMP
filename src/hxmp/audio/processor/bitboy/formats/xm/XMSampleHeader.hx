package hxmp.audio.processor.bitboy.formats.xm;

import flash.utils.ByteArray;
import flash.geom.Point;

class XMSampleHeader 
{

	public var size:UInt;
	
	public var sampleNumber:Array<UInt>;
	
	public var volumeEnvelope:Array<Point>;
	public var panningEnvelope:Array<Point>;
	
	public var numVolumePoints:UInt;
	public var numPanningPoints:UInt;
	
	public var volumeSustainPoint:UInt;
	public var volumeLoopStartPoint:UInt;
	public var volumeLoopEndPoint:UInt;
		
	public var panningSustainPoint:UInt;
	public var panningLoopStartPoint:UInt;
	public var panningLoopEndPoint:UInt;
	
	public var volumeType:UInt;
	public var panningType:UInt;
		
	public var vibratoType:UInt;
	public var vibratoSweep:UInt;
	public var vibratoDepth:UInt;
	public var vibratoRate:UInt;
		
	public var volumeFadeOut:UInt;
	
	public function new(stream:ByteArray)
	{
		parse(stream);
	}
	
	private function parse(stream:ByteArray)
	{
		var i:Int;
		var x:Int;
		var y:Int;
		
		size = stream.readUnsignedInt();
		// sampleNumber = new Array(96);
		sampleNumber = new Array<UInt>();
		
		for (i in 0...96)
		{
			sampleNumber[ i ] = stream.readUnsignedByte();
		}
		
		// volumeEnvelope = new Array(12);
		volumeEnvelope = new Array<Point>();
		
		for (i in 0...12)
		{
			x = stream.readUnsignedShort();
			y = stream.readUnsignedShort();
			
			volumeEnvelope[i] = new Point(x, y);
		}
		
		// panningEnvelope = new Array(12);
		panningEnvelope = new Array<Point>();
		
		for (i in 0...12)
		{
			x = stream.readUnsignedShort();
			y = stream.readUnsignedShort();
			
			panningEnvelope[i] = new Point(x, y);
		}
		
		numVolumePoints = stream.readUnsignedByte();
		
		if (numVolumePoints > 12)
		{
			trace('Waning:numVolumePoints is greater than 12 which should be the maximum.');
			numVolumePoints = 12;
		}
		
		numPanningPoints = stream.readUnsignedByte();
		
		if (numPanningPoints > 12)
		{
			trace('Waning:numPanningPoints is greater than 12 which should be the maximum.');
			numPanningPoints = 12;
		}
		
		volumeSustainPoint = stream.readUnsignedByte();
		volumeLoopStartPoint = stream.readUnsignedByte();
		volumeLoopEndPoint = stream.readUnsignedByte();
		
		panningSustainPoint = stream.readUnsignedByte();
		panningLoopStartPoint = stream.readUnsignedByte();
		panningLoopEndPoint = stream.readUnsignedByte();
		
		//TODO:implement this bitflag
		// Volume type:bit 0:On; 1:Sustain; 2:Loop
		volumeType = stream.readUnsignedByte();

		//TODO:implement this bitflag
		// Panning type:bit 0:On; 1:Sustain; 2:Loop
		panningType = stream.readUnsignedByte();
	
		vibratoType = stream.readUnsignedByte();
		vibratoSweep = stream.readUnsignedByte();
		vibratoDepth = stream.readUnsignedByte();
		vibratoRate = stream.readUnsignedByte();
		
		volumeFadeOut = stream.readUnsignedShort();
		
		//-- unused
		stream.readMultiByte(11, XMFormat.ENCODING);
	}
	
	public function toString():String
	{
		var ENUM:Array<String> = ['size',
			'sampleNumber',
			'volumeEnvelope',
			'panningEnvelope',
			'numVolumePoints',
			'numPanningPoints',
			'volumeSustainPoint',
			'volumeLoopStartPoint',
			'volumeLoopEndPoint',
			'panningSustainPoint',
			'panningLoopStartPoint',
			'panningLoopEndPoint',
			'volumeType',
			'panningType',
			'vibratoType',
			'vibratoSweep',
			'vibratoDepth',
			'vibratoRate',
			'volumeFadeOut'];
		
		var result:String = '[XMSampleHeader';
		
		var i:Int;
		for (i in 0...ENUM.length)
		{
			result += (i == 0 ? ' ' :', ') + ENUM[i] + ':';// + this[ENUM[i]];
		}
		
		return result + ']';
	}
	
}