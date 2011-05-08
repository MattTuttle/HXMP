/**
 * ...
 * @author Matt Tuttle
 */

package hxmp.audio.processor.bitboy.formats.mod;
import flash.utils.ByteArray;

class ModSample 
{

	public var title:String;
	public var length:Int;
	public var tone:Int;
	public var volume:Int;
	public var repeatStart:Int;
	public var repeatLength:Int;
	public var waveform:ByteArray;
	public var wave:Array<Float>;
	
	public function new(stream:ByteArray)
	{
		if(stream != null)
			parse(stream);
	}
	
	public function loadWaveform(stream:ByteArray)
	{
		if (length == 0)
			return;

		waveform = new ByteArray();
		
		wave = new Array<Float>();
		
		var value:Float;
		var min:Float = 1;
		var max:Float = -1;
		
		var i:Int;
		
		for (i in 0...length)
		{
			value = (stream.readByte() + .5) / 127.5;
			
			if(value < min) min = value;
			if(value > max) max = value;
			
			wave.push(value);
		}
		
		var base:Float = (min + max) / 2;
		
		for (i in 0...length)
			wave[i] -= base;
	}
	
	private function parse(stream: ByteArray)
	{
		stream.position = 0;
		title = '';
		
		//-- read 22 chars into the title
		//   we dont break if we reach the NUL char cause this would turn
		//   the stream.position wrong
		var i:Int;
		for (i in 0...22)
		{
			var char:Int = stream.readByte();
			if (char != 0)
				title += String.fromCharCode(char);
		}
		
		length = stream.readUnsignedShort();
		tone = stream.readUnsignedByte(); //everytime 0
		volume = stream.readUnsignedByte();
		repeatStart = stream.readUnsignedShort();
		repeatLength = stream.readUnsignedShort();

		//-- turn it into bytes
		length <<= 1;
		repeatStart <<= 1;
		repeatLength <<= 1;
	}
	
	public function clone(): ModSample
	{
		var sample: ModSample = new ModSample(null);
		
		sample.title = title;
		sample.length = length;
		sample.tone = tone;
		sample.volume = volume;
		sample.repeatStart = repeatStart;
		sample.repeatLength = repeatLength;
		sample.waveform = waveform;
		sample.wave = wave;
		
		return sample;
	}
	
	public function toString(): String
	{
		return '[MOD Sample'
			+ ' title: '+ title
			+ ', length: ' + length
			+ ', tone: ' + tone
			+ ', volume: ' + volume
			+ ', repeatStart: ' + repeatStart
			+ ', repeatLength: ' + repeatLength
			+ ']';
	}
	
}