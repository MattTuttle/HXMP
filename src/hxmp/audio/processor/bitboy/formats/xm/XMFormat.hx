package hxmp.audio.processor.bitboy.formats.xm;

import flash.utils.ByteArray;
import flash.utils.Endian;
import hxmp.audio.processor.bitboy.BitBoy;
import hxmp.audio.processor.bitboy.channel.ChannelBase;
import hxmp.audio.processor.bitboy.channel.XMChannel;
import hxmp.audio.processor.bitboy.formats.FormatBase;
import hxmp.audio.processor.bitboy.formats.TriggerBase;

class XMFormat extends FormatBase
{

	public static inline var ENCODING:String = 'us-ascii';
	
	private static inline var MAX_CHANNELS:UInt = 0x20;
	private static inline var MAX_INSTRUMENTS:UInt = 0x80;
	private static inline var MAX_PATTERNS:UInt = 0x100;
	private static inline var MAX_LENGTH:UInt = 0x100;
	
	//public var patterns:Array;
	
	//public var sequence:Array; //pattern order
	//public var length:UInt; //sequence length
	//public var restartPosition:UInt;
	
	//public var title:String;
	
	//public var numChannels:UInt;
	//public var numPatterns:UInt;
	public var numInstruments:UInt;
	
	public var useLinearSlides:Bool;
	
	public var defaultTempo:UInt;
	public var defaultBPM:UInt;
	
	private var instruments:Array<XMInstrument>;
	
	static public function decode(stream:ByteArray):XMFormat
	{
		return new XMFormat(stream);
	}
	
	public function new(stream:ByteArray)
	{
		super(stream);
		
		instruments = new Array<XMInstrument>();
		
		parse(stream);
	}
	
	override public function getTriggerAt(patternIndex:Int, rowIndex:Int, channelIndex:Int):TriggerBase
	{
		var pattern:XMPattern = cast(patterns[patternIndex], XMPattern);
		trace("row: " + rowIndex + " channel: " + channelIndex);
		return pattern.rows[rowIndex][channelIndex];
	}
	
	override public function getChannels(bitboy:BitBoy):Array<ChannelBase>
	{
		var i:Int;
		var array:Array<ChannelBase> = new Array<ChannelBase>();
		for (i in 0...numChannels)
			array.push(new XMChannel(bitboy, i, 0.0));
		return array;
	}
	
	override private function parse(stream:ByteArray)
	{
		var i:Int;
		
		stream.position = 0;
		stream.endian = Endian.LITTLE_ENDIAN;
		
		var idText:String = stream.readMultiByte(17, ENCODING);
		title = stream.readMultiByte(20, ENCODING);
		
		if (idText.toLowerCase() != 'extended module: ')
			throw new XMFormatError(XMFormatError.FILE_CORRUPT);
			
		if (stream.readUnsignedByte() != 0x1a)
			throw new XMFormatError(XMFormatError.FILE_CORRUPT);
			
		var trackerName:String = stream.readMultiByte(20, ENCODING);
		
		var version:UInt = stream.readUnsignedShort();
		
		if (version > 0x0104) //01 = major, 04 = minor
			throw new XMFormatError(XMFormatError.NOT_IMPLEMENTED);
		
		var headerSize:UInt = stream.readUnsignedInt();
		
		length = stream.readUnsignedShort(); //songLength in patterns
		
		if (length > MAX_LENGTH)
			throw new XMFormatError(XMFormatError.MAX_LENGTH);
		
		restartPosition = stream.readUnsignedShort();
		
		numChannels = stream.readUnsignedShort();
		
		if (numChannels > MAX_CHANNELS)
			throw new XMFormatError(XMFormatError.MAX_CHANNELS);
		
		numPatterns = stream.readUnsignedShort();
		
		if (numPatterns > MAX_PATTERNS)
			throw new XMFormatError(XMFormatError.MAX_PATTERNS);
		
		numInstruments = stream.readUnsignedShort();
		
		if (numInstruments > MAX_INSTRUMENTS)
			throw new XMFormatError(XMFormatError.MAX_INSTRUMENTS);
		
		var flags:UInt = stream.readUnsignedShort();
		
		useLinearSlides = ((flags & 1) == 1);
		
		defaultTempo = stream.readUnsignedShort();
		
		defaultBPM = stream.readUnsignedShort();
		
		//sequence = new Array(length);
		sequence = new Array<UInt>();
		
		for (i in 0...length)
		{
			sequence[i] = stream.readUnsignedByte();
		}
		
		stream.position += 0x100 - length;
		
		//-- seek to instruments by getting pattern headers
		for (i in 0...numPatterns)
		{
			patterns.push(new XMPattern(stream));
		}
		
		//-- parse instruments
		for (i in 0...numInstruments)
		{
			instruments.push(new XMInstrument(stream, i + 1));
		}
		
		//-- parse pattern data now
		for (i in 0...numPatterns)
		{
			var pattern:XMPattern = cast(patterns[i], XMPattern);
			pattern.parseData(stream, numChannels, instruments);
		}
		
		// access a trigger:
		// patternId = id of pattern
		// rowNumber = number of row in pattern
		// channelNumber = desired channel
		//
		// XMTrigger(XMPattern(patterns[ patternId ]).rows[ rowNumber ][ channelNumber ])
	}
	
}