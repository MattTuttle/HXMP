package hxmp.audio.processor.bitboy.channel;

import hxmp.audio.processor.bitboy.BitBoy;
import hxmp.audio.processor.bitboy.formats.TriggerBase;
import hxmp.audio.output.Sample;

class XMChannel extends ChannelBase
{

	public function new(bitboy:BitBoy, id:Int, pan:Float)
	{
		super(bitboy, id, pan);
	}
	
	public override function reset()
	{
		
	}
	
	public override function onTrigger(trigger:TriggerBase)
	{
		
	}
	
	public override function onTick(tick:Int)
	{
		
	}
	
	public override function processAudioAdd(samples:Array<Sample>, numSamples:Int, pointerIndex:Int)
	{
		
	}
	
}