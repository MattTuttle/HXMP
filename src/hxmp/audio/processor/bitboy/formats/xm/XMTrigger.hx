package hxmp.audio.processor.bitboy.formats.xm;

import flash.utils.ByteArray;
import hxmp.audio.processor.bitboy.formats.TriggerBase;

class XMTrigger extends TriggerBase
{

	private var instrumentIndex:UInt;
	
	public var note:Int;
	public var instrument:XMInstrument;
	
	public var volume:UInt;
	public var volumeCommand:UInt;
	public var hasVolume:Bool; //is a volume command executed?
	
	//public var effect:Int;
	//public var effectParam:Int;
	//public var hasEffect:Bool; //is a effect command executed?
	
	public function new(stream:ByteArray, instruments:Array<XMInstrument>)
	{
		super();
		parse(stream, instruments);
	}
	
	private function parse(stream:ByteArray, instruments:Array<XMInstrument>)
	{
		var type:Int = stream.readUnsignedByte();
		
		volume = 0;
		volumeCommand = XMVolumeCommand.NO_COMMAND;
		
		if ((type & 0x80) != 0)
		{
			if ((type & 0x01) != 0) note = stream.readUnsignedByte();
			if ((type & 0x02) != 0) instrumentIndex = stream.readUnsignedByte();
			if ((type & 0x04) != 0)	volume = stream.readUnsignedByte();
			if ((type & 0x08) != 0)	effect = stream.readUnsignedByte();
			if ((type & 0x10) != 0)	effectParam = stream.readUnsignedByte();
		}
		else
		{
			note = type;
			instrumentIndex = stream.readUnsignedByte();
			volume = stream.readUnsignedByte();
			effect = stream.readUnsignedByte();
			effectParam = stream.readUnsignedByte();
		}
		
		if (note == 97)
		{
			// ModPlug displays these notes as == and sets
			// their value internal to 0xff
			note = 0xff;
		}
		else
		{
			if (note > 0 && note < 97)
			{
				note += 12;
				//do we need this?
			}
		}
		
		hasEffect = (effect | effectParam) != 0;
		
		if (instrumentIndex == 0xff)
			instrumentIndex = 0;
			
		if (instrumentIndex != 0)
		{
			instrument = instruments[instrumentIndex - 1];
		}
						
		if (volume >= 0x10 && volume <= 0x50)
		{
			volumeCommand = XMVolumeCommand.VOLUME;
			volume -= 0x10;
		}
		else if (volume >= 0x60)
		{
			volumeCommand = volume & 0xf0;
			volume &= 0x0f;
		}
		
		if (volume == 0 && volumeCommand == XMVolumeCommand.NO_COMMAND)
		{
			hasVolume = false;
		}
		else
		{
			hasVolume = true;
		}
	}
	
	override public function toString():String
	{
		return '[XMTrigger instrument:' + instrument + ', volume:' + volume + ', effect:0x' + Std.string(effect) + ', effectParam:0x' + Std.string(effectParam) + ']';
	}
	
}