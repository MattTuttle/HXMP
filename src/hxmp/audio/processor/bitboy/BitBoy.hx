package hxmp.audio.processor.bitboy;

import flash.Lib;
import hxmp.audio.output.Sample;
import hxmp.audio.output.Audio;
import hxmp.audio.processor.bitboy.formats.TriggerBase;
import hxmp.audio.processor.bitboy.formats.FormatBase;
import hxmp.audio.processor.bitboy.channel.ChannelBase;
import hxmp.parameter.MappingBoolean;
import hxmp.parameter.MappingIntLinear;
import hxmp.parameter.MappingFloatLinear;
import hxmp.parameter.Parameter;

class BitBoy 
{
	private static inline var RATIO:Float = 2.5;
	
	public var parameterGain:Parameter;
	public var parameterMute:Parameter;
	public var parameterPause:Parameter;
	public var parameterChannel:Parameter;
	public var parameterLoopMode:Parameter;
	
	private var format:FormatBase;
	private var channels:Array<ChannelBase>;
	private var length:Int;
	private var rate:Float;
	private var bpm:Float;
	private var speed:Int;

	private var tick:Int;
	private var rowIndex:Int;
	private var patIndex:Int;
	
	private var incrementPatIndex:Bool;

	private var samplesPerTick:Int;		
	private var rest:Int;
	
	private var complete:Bool;
	private var lastRow:Bool;
	private var idle:Bool;
	private var loop:Bool;
	
	/**
	 * Create a Bitboy instance
	 */
	public function new()
	{
		parameterGain = new Parameter(new MappingFloatLinear(0, 1), .75);
		parameterMute = new Parameter(new MappingBoolean(), false);
		parameterPause = new Parameter(new MappingBoolean(), false);
		parameterChannel = new Parameter(new MappingIntLinear(0, 0xf), 0xf);
		parameterLoopMode = new Parameter(new MappingBoolean(), false);
	}
	
	/**
	 * Returns true is lastRow
	 */
	public function isIdle():Bool
	{
		return idle;
	}
	
	/**
	 * set the mod format
	 */
	public function setFormat(format:FormatBase)
	{
		this.format = format;
		
		init();
		
		length = computeLengthInSeconds();
		
		reset();
	}
	
	/**
	 * returns song length in seconds. returns -1 if the loop is looped
	 */
	public function getLengthSeconds():Int
	{
		return length;
	}
	
	/**
	 * process audio stream
	 * 
	 * param samples The samples Array to be filled
	 */
	public function processAudio(samples:Array<Sample>)
	{
		if(complete)
		{
			idle = true;
			return;
		}
		
		var channel: ChannelBase;
		
		var pointer:Int = 0;
		var available:Int = samples.length;
		
		if (0 < rest)
		{
			for (channel in channels)
				channel.processAudioAdd(samples, rest, pointer);
			
			pointer += rest;
			available -= rest;
		}
		
		nextTick();
		
		while (available >= samplesPerTick)
		{
			for (channel in channels)
				channel.processAudioAdd(samples, samplesPerTick, pointer);
			
			pointer += samplesPerTick;
			available -= samplesPerTick;
			
			if (0 < available)
				nextTick();
		}
		
		if(0 < available)
		{
			for (channel in channels)
				channel.processAudioAdd(samples, available, pointer);
		}
		
		rest = samplesPerTick - available;
	}
	
	public function reset()
	{
		rate = Audio.RATE44100;
		speed = format.defaultSpeed;
		tick = 0;
		
		setBPM(format.defaultBpm);
		
		rowIndex = 0;
		patIndex = 0;
		
		complete = false;
		lastRow = false;
		idle = false;
		loop = false;
		incrementPatIndex = false;
		
		var channel:ChannelBase;
		for (channel in channels)
			channel.reset();
	}
	
	public function setBPM(bpm:Int)
	{
		samplesPerTick = Std.int(rate * RATIO / bpm);
		
		this.bpm = bpm;
	}
	
	public function setSpeed(speed:Int)
	{
		this.speed = speed;
	}
	
	public function setRowIndex(rowIndex:Int)
	{
		this.rowIndex = rowIndex;
	}
	
	public function getRowIndex():Int
	{
		return rowIndex;
	}
	
	public function getRate():Float
	{
		return rate;
	}
	
	public function patternJump(patIndex:Int)
	{
		if( patIndex <= this.patIndex )
			loop = true;
		
		this.patIndex = patIndex;
		
		setRowIndex( 0 );
	}
	
	public function patternBreak(rowIndex:Int)
	{
		setRowIndex( rowIndex );
		
		incrementPatIndex = true;
	}

	private function init()
	{
		channels = format.getChannels(this);
	}
	
	private function nextTick()
	{
		if( --tick <= 0 )
		{
			if( lastRow )
				complete = true;
			else
			{
				rowComplete();
				tick = speed;
			}
		}
		else
		{
			var channel:ChannelBase;
			for (channel in channels)
				channel.onTick(tick);
		}
	}
	
	private function rowComplete()
	{
		var channel: ChannelBase;
		//-- sync all parameter changes for smooth cuttings
		//
		
		if (!parameterPause.getValue())
		{
			var mutes:Int;
			
			if (parameterMute.getValue())
				mutes = 0;
			else
				mutes = parameterChannel.getValue();
			
			var i:Int;
			for (i in 0...format.numChannels)
			{
				channel = channels[i];
				
				channel.setMute( ( mutes & ( 1 << i ) ) == 0 );
			}
			
			nextRow();
		}
		else
		{
			for ( channel in channels )
				channel.setMute( true );
		}		
	}
	
	private function nextRow()
	{
		var channel:ChannelBase;
		var channelIndex:Int;
		
		var currentPatIndex:Int = patIndex;
		var currentRowIndex:Int = rowIndex++;
		
		incrementPatIndex = false;
		
		for (channelIndex in 0...format.numChannels)
		{
			channel = channels[channelIndex];
			channel.onTrigger(format.getTriggerAt(format.getSequenceAt(currentPatIndex), currentRowIndex, channelIndex));
		}
		
		if( incrementPatIndex )
		{
			nextPattern();
		}
		else if (rowIndex == format.getPatternLength(format.getSequenceAt(currentPatIndex)))
		{
			rowIndex = 0;
			nextPattern();
		}
	}
	
	private function nextPattern()
	{
		if(++patIndex == format.length)
		{
			if( parameterLoopMode.getValue() )
				patIndex = format.restartPosition;
			else
				lastRow = true;
		}
	}
	
	private function computeLengthInSeconds():Int
	{
		reset();
		
		var channel: ChannelBase;
		var channelIndex:Int;
		
		var currentPatIndex:Int;
		var currentRowIndex:Int;
		
		var samplesTotal:Float = 0;
		
		var ms:Int = Lib.getTimer();
		
		while(Lib.getTimer() - ms < 1000) // just be save
		{
			if( lastRow )
				break;
			
			currentPatIndex = patIndex;
			currentRowIndex = rowIndex++;
			incrementPatIndex = false;
			
			for (channelIndex in 0...format.numChannels)
			{
				channel = channels[channelIndex];
				channel.onTrigger(format.getTriggerAt(format.getSequenceAt(currentPatIndex), currentRowIndex, channelIndex));
			}
			
			if ( loop )
				return -1;
			
			if ( incrementPatIndex )
				nextPattern();
			
			if (rowIndex == format.getPatternLength(format.getSequenceAt(currentPatIndex)))
			{
				rowIndex = 0;
				nextPattern();
			}
			
			samplesTotal += samplesPerTick * speed;
		}
		
		return Std.int(samplesTotal / rate);
	}
}