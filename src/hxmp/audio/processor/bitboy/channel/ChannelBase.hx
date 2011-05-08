package hxmp.audio.processor.bitboy.channel;

import flash.errors.Error;
import hxmp.audio.output.Sample;
import hxmp.audio.processor.bitboy.BitBoy;
import hxmp.audio.processor.bitboy.formats.TriggerBase;

class ChannelBase 
{

	private var bitboy:BitBoy;
	private var id:Int;
	private var pan:Float;
	
	private var trigger:TriggerBase;
	
	/* PITCH */
	private var tone:Int;
	private var period:Int;
	
	private var linearPeriod:Float;
	
	/* EFFECT */
	private var effect:Int;
	private var effectParam:Int;
	
	private var mute:Bool;
	
	public function new(bitboy:BitBoy, id:Int, pan:Float)
	{
		this.bitboy = bitboy;
		this.pan = pan;
		this.id = id;
	}
	
	public function setMute(value:Bool)
	{
		mute = value;
	}
	
	public function reset()
	{
		throw new Error('Override Implementation!');
	}
	
	public function onTrigger(trigger: TriggerBase)
	{
		throw new Error('Override Implementation!');
	}
	
	public function onTick(tick:Int)
	{
		throw new Error('Override Implementation!');
	}
	
	public function processAudioAdd(samples:Array<Sample>, numSamples:Int, pointerIndex:Int)
	{
		throw new Error('Override Implementation!');
	}
		
	public function toString(): String
	{
		return '[ChannelBase]';
	}
	
}