package hxmp.audio.processor.bitboy.channel;

import hxmp.audio.output.Sample;
import hxmp.audio.processor.bitboy.BitBoy;
import hxmp.audio.processor.bitboy.formats.mod.ModSample;
import hxmp.audio.processor.bitboy.formats.TriggerBase;
import hxmp.audio.processor.bitboy.formats.mod.ModTrigger;

class Arpeggio
{
	public var p0:Int;
	public var p1:Int;
	public var p2:Int;
	
	public function new(p0:Int, p1:Int, p2:Int)
	{
		this.p0 = p0;
		this.p1 = p1;
		this.p2 = p2;
	}
}

class ModChannel extends ChannelBase
{

	static private inline var ARPEGGIO:Int = 0x0;
	static private inline var PORTAMENTO_UP:Int = 0x1;
	static private inline var PORTAMENTO_DN:Int = 0x2;
	static private inline var TONE_PORTAMENTO:Int = 0x3;
	static private inline var VIBRATO:Int = 0x4;
	static private inline var TONE_PORTAMENTO_VOLUME_SLIDE:Int = 0x5;
	static private inline var VIBRATO_VOLUME_SLIDE:Int = 0x6;
	static private inline var TREMOLO:Int = 0x7;
	static private inline var SET_PANNING:Int = 0x8;
	static private inline var SAMPLE_OFFSET:Int = 0x9;
	static private inline var VOLUME_SLIDE:Int = 0xa;
	static private inline var POSITION_JUMP:Int = 0xb;
	static private inline var SET_VOLUME:Int = 0xc;
	static private inline var PATTERN_BREAK:Int = 0xd;
	static private inline var EXTENDED_EFFECTS:Int = 0xe;
	static private inline var SET_SPEED:Int = 0xf;
	
	static private inline var TONE_TABLE: Array<Int> =
	[
		856,808,762,720,678,640,604,570,538,508,480,453,
		428,404,381,360,339,320,302,285,269,254,240,226,
		214,202,190,180,170,160,151,143,135,127,120,113
	];
	
	static private inline var SINE_TABLE: Array<Int> =
	[
		0,24,49,74,97,120,141,161,
		180,197,212,224,235,244,250,253,
		255,253,250,244,235,224,212,197,
		180,161,141,120,97,74,49,24,
		0,-24,-49,-74,-97,-120,-141,-161,
		-180,-197,-212,-224,-235,-244,-250,-253,
		-255,-253,-250,-244,-235,-224,-212,-197,
		-180,-161,-141,-120,-97,-74,-49,-24
	];
	
	private var wave:Array<Float>;
	private var wavePhase:Float;
	private var repeatStart:Int;
	private var repeatLength:Int;
	private var firstRun:Bool;
	private var volume:Int;
	
	private var volumeSlide:Int;
	private var portamentoSpeed:Int;
	private var tonePortamentoSpeed:Int;
	private var tonePortamentoPeriod:Int;
	private var vibratoSpeed:Int;
	private var vibratoDepth:Int;
	private var vibratoPosition:Int;
	private var vibratoOffset:Int;
	private var arpeggio:Arpeggio;
	
	//-- EXT EFFECT
	private var patternfirstRun:Bool;
	private var patternfirstRunCount:Int;
	private var patternfirstRunPosition:Int;
	
	public function new(bitboy:BitBoy, id:Int, pan:Float)
	{
		super(bitboy, id, pan);
	}
	
	public override function setMute(value:Bool)
	{
		mute = value;
	}
	
	public override function reset()
	{
		wave = null;
		wavePhase = 0.0;
		repeatStart = 0;
		repeatLength = 0;
		firstRun = false;
		volume = 0;
		trigger = null;
		
		patternfirstRun = false;
		patternfirstRunCount = 0;
		patternfirstRunPosition = 0;
		
		volumeSlide = 0;
		portamentoSpeed = 0;
		tonePortamentoSpeed = 0;
		tonePortamentoPeriod = 0;
		vibratoSpeed = 0;
		vibratoDepth = 0;
		vibratoPosition = 0;
		vibratoOffset = 0;
		
		effect = 0;
		effectParam = 0;
	}
	
	public override function onTrigger(trigger:TriggerBase)
	{
		this.trigger = trigger;
		
		updateWave();
		
		if( trigger.effect == TONE_PORTAMENTO  )
		{
			initTonePortamento();
		}
		else if( trigger.period > 0 )
		{
			period = trigger.period;
			tone = Lambda.indexOf(TONE_TABLE, period);
			tonePortamentoPeriod = period; // fix for 'delicate.mod'
			arpeggio = null;
		}
		
		initEffect();
	}
	
	public override function onTick(tick:Int)
	{
		switch(effect)
		{
			case ARPEGGIO:
				updateArpeggio( tick % 3 );
			
			case PORTAMENTO_UP:
			case PORTAMENTO_DN:
				updatePortamento();
			
			case TONE_PORTAMENTO:
				updateTonePortamento();
				
			case TONE_PORTAMENTO_VOLUME_SLIDE:
				updateTonePortamento();
				updateVolumeSlide();
			
			case VOLUME_SLIDE:
				updateVolumeSlide();
			
			case VIBRATO:
				updateVibrato();
			
			case VIBRATO_VOLUME_SLIDE:
				updateVibrato();
				updateVolumeSlide();
			
			case EXTENDED_EFFECTS:
				var extEffect:Int = effectParam >> 4;
				var extParam:Int = effectParam & 0xf;
				
				switch (extEffect)
				{
					case 0x9: //-- retrigger note
						if (tick % extParam == 0)
							wavePhase = 0.0;
					
					case 0xc: //-- cut note
						wave = null;
				}
		}
	}
	
	public override function processAudioAdd(samples:Array<Sample>, numSamples:Int, pointerIndex:Int)
	{
		if(wave == null || mute)
			return;
		
		var sample: Sample;
		
		var len:Int = wave.length;
		
		var volT:Float = ( volume / 64 ) * bitboy.parameterGain.getValue();
		var volL:Float = volT * ( 1 - pan ) / 2;
		var volR:Float = volT * ( pan + 1 ) / 2;
		
		var waveSpeed:Float = ( ( 7159090.5 / 2 ) / bitboy.getRate() ) / ( period + vibratoOffset ); // NTSC machine clock (Magic Number)
		
		var phaseInt:Int;
		var alpha:Float;
		var amp:Float;
		
		var i:Int;
		for(i in 0...numSamples)
		{
			if( firstRun )
			{
				if( wavePhase >= len ) // first run complete
				{
					if( repeatLength == 0 ) // stop channel
					{
						wave = null;
						return;
					}
					else
					{
						//-- truncate
						wave = wave.slice( repeatStart, repeatStart + repeatLength );
						len = wave.length;
						wavePhase %= len;
						firstRun = false;
					}
				}
			}
			else
				wavePhase %= len;
			
			//-- LINEAR INTERPOLATION
			//
			phaseInt = Std.int(wavePhase);
			alpha = wavePhase - phaseInt;

			amp = wave[ phaseInt ] * ( 1 - alpha );
			if( ++phaseInt == len ) phaseInt = 0;
			amp += wave[ phaseInt ] * alpha;
			
			sample = samples[Std.int( i + pointerIndex )];
			sample.left += amp * volL;
			sample.right += amp * volR;
			
			wavePhase += waveSpeed;
		}
	}

	private function initEffect()
	{
		if( trigger == null )
			return;
		
		effect = trigger.effect;
		effectParam = trigger.effectParam;
		
		if( effect != VIBRATO && effect != VIBRATO_VOLUME_SLIDE )
		{
			vibratoOffset = 0;
		}
		
		switch( effect )
		{
			case ARPEGGIO:
				if( effectParam > 0 )
				{
					initArpeggio();
				}
				else
				{
					//-- no effect here, reset some values
					volumeSlide = 0;
				}
			
			case PORTAMENTO_UP:
				initPortamento( -effectParam );
			
			case PORTAMENTO_DN:
				initPortamento( effectParam );
				
			case TONE_PORTAMENTO:
				return;
			
			case VIBRATO:
				if (cast(trigger, ModTrigger).modSample != null)
					volume = cast(trigger, ModTrigger).modSample.volume;
				initVibrato();

			case VIBRATO_VOLUME_SLIDE:
				/*This is a combination of Vibrato (4xy), and volume slide (Axy).
				The parameter does not affect the vibrato, only the volume.
				If no parameter use the vibrato parameters used for that channel.*/
				initVolumeSlide();
			
			case SET_PANNING:
				initPanning();
		
			case EXTENDED_EFFECTS:
				var extEffect:Int = effectParam >> 4;
				var extParam:Int = effectParam & 0xf;
			
				switch ( extEffect )
				{
					case 0x6: //-- pattern firstRun
						if( extParam == 0 )
						{
							patternfirstRunPosition = bitboy.getRowIndex() - 1;
						}
						else
						{
							if( !patternfirstRun )
							{
								patternfirstRunCount = extParam;
								patternfirstRun = true;
							}
							
							if( --patternfirstRunCount >= 0 )
							{
								bitboy.setRowIndex( patternfirstRunPosition );
							}
							else
							{
								patternfirstRun = false;
							}
						}
					
					case 0x9: //-- retrigger note
						wavePhase = .0;
					
					case 0xc: //-- cut note
						if( extParam == 0 )
							wave = null;
					
					default:
						trace( 'extended effect: ' + extEffect + ' is not defined.' );
				}
			
			case TONE_PORTAMENTO_VOLUME_SLIDE:
			case VOLUME_SLIDE:
				initVolumeSlide();
			
			case SET_VOLUME:
				volumeSlide = 0;
				volume = effectParam;
			
			case POSITION_JUMP:
				bitboy.patternJump( effectParam );
			
			case PATTERN_BREAK:
				bitboy.patternBreak(Std.parseInt(Std.string(effectParam)));
			
			case SET_SPEED:
				if( effectParam > 32 )
					bitboy.setBPM( effectParam );
				else
					bitboy.setSpeed( effectParam );
			
			default:
				trace( 'effect: ' + effect + ' is not defined.' );
		}
	}
	
	private function updateWave()
	{
		if( trigger == null )
			return;

		var modSample:ModSample = cast(trigger, ModTrigger).modSample;
		
		if( modSample == null || trigger.period <= 0 )
			return;

		wave = modSample.wave;
		wavePhase = 0.0;
		repeatStart = modSample.repeatStart;
		repeatLength = modSample.repeatLength;
		volume = modSample.volume;
		firstRun = true;
	}
	
	private function initArpeggio()
	{
		arpeggio = new Arpeggio
		(
			period,
			TONE_TABLE[ tone + ( effectParam >> 4 ) ],
			TONE_TABLE[ tone + ( effectParam & 0xf ) ]
		);
	}
	
	private function updateArpeggio( index:Int )
	{
		if( effectParam > 0 )
		{
			if( index == 1 )
				period = arpeggio.p2;
			else if( index == 2 )
				period = arpeggio.p1;
		}
	}
	
	private function initVolumeSlide()
	{
		if(cast(trigger, ModTrigger).modSample != null)
			volume = cast(trigger, ModTrigger).modSample.volume;
		volumeSlide =  effectParam >> 4;
		volumeSlide -= effectParam & 0xf;
	}
	
	private function updateVolumeSlide()
	{
		var newVolume:Int = volume + volumeSlide;

		if( newVolume < 0 ) newVolume = 0;
		else if( newVolume > 64 ) newVolume = 64;
		
		volume = newVolume;
	}
	
	private function initPanning()
	{
		pan = (trigger.effectParam - 64) / 128;
	}
	
	private function initTonePortamento()
	{
		if( trigger.effectParam > 0 )
		{
			tonePortamentoSpeed = trigger.effectParam;
			if( trigger.period > 0 )
			{
				tonePortamentoPeriod = trigger.period;
			}
		}
	}
	
	private function updateTonePortamento()
	{
		if( period > tonePortamentoPeriod )
		{
			period -= tonePortamentoSpeed;
			if( period < tonePortamentoPeriod )
				period = tonePortamentoPeriod;
		}
		else if( period < tonePortamentoPeriod )
		{
			period += tonePortamentoSpeed;
			if( period > tonePortamentoPeriod )
				period = tonePortamentoPeriod;
		}
	}
	
	private function initPortamento( portamentoSpeed:Int )
	{
		this.portamentoSpeed = portamentoSpeed;
	}
	
	private function updatePortamento()
	{
		period += portamentoSpeed;
	}
	
	private function initVibrato()
	{
		if( effectParam > 0 )
		{
			vibratoSpeed = effectParam >> 4;
			vibratoDepth = effectParam & 0xf;
			vibratoPosition = 0;
		}
	}
	
	private function updateVibrato()
	{
		vibratoPosition += vibratoSpeed;
		
		vibratoOffset = Std.int( SINE_TABLE[ vibratoPosition % SINE_TABLE.length ] * vibratoDepth / 128 );
	}
	
}