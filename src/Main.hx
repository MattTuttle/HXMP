import flash.events.SampleDataEvent;
import flash.Lib;
import flash.media.Sound;
import flash.utils.ByteArray;

import hxmp.audio.output.SoundFactory;

import hxmp.format.wav.WavFormat;
import hxmp.audio.output.Audio;
import hxmp.audio.output.Sample;
import hxmp.audio.processor.bitboy.BitBoy;
import hxmp.audio.processor.bitboy.formats.FormatBase;
import hxmp.audio.processor.bitboy.formats.FormatFactory;

class Main
{
	
	static public inline var BUFFER_SIZE:Int = 4096;
	
	public var bitboy:BitBoy;
	public var buffer:Array<Sample>;
	public var sound:Sound;
	public var isRunning:Bool;
	
	public static function main()
	{
		new Main();
	}
	
	public function new()
	{
		initAudioEngine();
	}
	
	private function initAudioEngine()
	{
		var format:FormatBase = FormatFactory.createFormat(new MusicTest());
		
		bitboy = new BitBoy();
		bitboy.setFormat(format);
		bitboy.parameterPause.setValue(false);
		
		buffer = new Array<Sample>();
		
		var i:Int;
		for(i in 0...BUFFER_SIZE)
			buffer[i] = new Sample();
		
		sound = new Sound();
		sound.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
		sound.play();
		
		isRunning = true;
	}
	
	private function onSampleData(event:SampleDataEvent)
	{
		if(isRunning)
		{
			bitboy.processAudio(buffer);
			
//			if(bassBoost) bassBoost.processAudio( buffer );
//			if(stereoEnhancer) stereoEnhancer.processAudio( buffer );
		}
		
		var sample:Sample;
		
		var i:Int;
		var n:Int = BUFFER_SIZE;
		
		for (i in 0...n)
		{
			sample = buffer[i];
			
			event.data.writeFloat(sample.left);
			event.data.writeFloat(sample.right);
			
			sample.left = 0.0;
			sample.right = 0.0;
		}
	}
	
}