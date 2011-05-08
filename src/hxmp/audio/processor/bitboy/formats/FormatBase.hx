package hxmp.audio.processor.bitboy.formats;

import flash.errors.Error;
import flash.utils.ByteArray;
import hxmp.audio.processor.bitboy.channel.ChannelBase;
import hxmp.audio.processor.bitboy.BitBoy;
import hxmp.audio.processor.bitboy.channel.ModChannel;

class FormatBase 
{
	
	private var patterns:Array<Dynamic>;
	
	private var sequence:Array<UInt>;
	
	public var length:Int;
	
	public var title:String;
	
	public var numChannels:UInt;
	
	public var numPatterns:UInt;
	
	public var credits:Array<String>;
	
	public var restartPosition:Int;
	
	public var defaultBpm:Int;
	
	public var defaultSpeed:Int;
	
	public function new(stream:ByteArray)
	{
		patterns = new Array<Dynamic>();
		sequence = new Array<UInt>();
		
		length = 0;
		title = '';
		
		numChannels = 0;
		numPatterns = 0;
		
		credits = new Array<String>();
	}
	
	private function parse(stream:ByteArray)
	{
		
	}
	
	public function getTriggerAt(patternIndex:Int, rowIndex:Int, channelIndex:Int):TriggerBase
	{
		return patterns[patternIndex][rowIndex][channelIndex];
	}
	
	public function getSequenceAt(sequenceIndex:Int):Int
	{
		return Std.int(sequence[sequenceIndex]);
	}
	
	/**
	 * Returns the number of rows in the pattern at given index.
	 * 
	 * @param patternIndex The index of the pattern.
	 * @return Number of rows.
	 */		
	public function getPatternLength(patternIndex:Int):Int
	{
		return patterns[patternIndex].length;
	}
	
	public function getChannels(bitboy:BitBoy):Array<ChannelBase>
	{
		throw new Error('Override Implementation!');
		return null;
	}
	
	public function toString():String
	{
		return '[FormatBase]';
	}
	
}