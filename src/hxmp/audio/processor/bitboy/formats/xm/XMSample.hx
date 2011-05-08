/**
 * ...
 * @author Matt Tuttle
 */

package hxmp.audio.processor.bitboy.formats.xm;
import flash.utils.ByteArray;

class XMSample 
{

	public var length:UInt;
	
	public var loopStart:UInt;
	public var loopLength:UInt;
	
	public var loop:Bool;
	public var pingPong:Bool;
	
	public var volume:UInt;
	public var fineTone:Int;
	
	public var type:UInt;
	
	public var panning:UInt;
	
	public var relativeNote:Int;
	
	public var wave:Array<Int>;
	public var name:String;
	
	//-- quick&dirty bitboy compatibility
	public var repeatStart:UInt;
	public var repeatEnd:UInt;
	
	public function new(stream:ByteArray, sampleHeaderSize:UInt = 0x28)
	{
		parse(stream, sampleHeaderSize);
	}
	
	private function parse(stream:ByteArray, sampleHeaderSize:UInt)
	{
		var i:Int;
		var p:Int = stream.position;
		
		length = stream.readUnsignedInt();
		
		loopStart = repeatStart = stream.readUnsignedInt();
		loopLength = stream.readUnsignedInt();
		repeatEnd = loopStart + loopLength;
		
		//NOTE: if sampleLoopLength == 0 then sample is NOT looping (even if sampleType or smth has it set)
		
		volume = stream.readUnsignedByte();
		fineTone = stream.readByte();
		
		type = stream.readUnsignedByte();
		panning = stream.readUnsignedByte();
		
		if ((type & 0x10) != 0)
		{
			trace('Error! Found a 16b sample');
			throw new XMFormatError(XMFormatError.NOT_IMPLEMENTED);
		}
		
		if ((type & 0x20) != 0)
		{
			trace('Error! Found a stereo sample');
			throw new XMFormatError(XMFormatError.NOT_IMPLEMENTED);
			
			if ((type & 0x10) != 0)
			{
				// stereo 16b
			}
			else
			{
				// stereo 8b
			}
		}
		
		if ((type & 2) != 0)
		{
			pingPong = true;
		}
		
		if ((type & 3) != 0)
		{
			loop = true;
		}

		if (loopLength == 0)
			loop = false;
			
		relativeNote = stream.readByte();
		
		//-- unused
		stream.readByte();
		
		name = stream.readMultiByte(22, XMFormat.ENCODING);


		stream.position = p + sampleHeaderSize;
				
		//-- decode delta-encoded sample
		var delta:Int = 0;	
		
		// wave = new Array(length);
		wave = new Array<Int>();
		
		for (i in 0...length)
		{
			delta += stream.readByte();
			wave[i] = delta;
		}
	}
	
	public function toString():String
	{
		var ENUM:Array<String> = ['length',
			'loopStart',
			'loopLength',
			'loop',
			'pingPong',
			'volume',
			'fineTone',
			'type',
			'panning',
			'relativeNote',
			'wave',
			'name'];
		
		var result:String = '[XMSample';
		
		var i:Int;
		for (i in 0...ENUM.length)
		{
			result += (i == 0 ? ' ' :', ') + ENUM[ i ] + ':' ;// + this[ENUM[i]];
		}
		
		return result + ']';
	}
	
}