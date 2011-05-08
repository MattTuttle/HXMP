package hxmp.format.wav;

import flash.utils.ByteArray;
import hxmp.audio.output.Sample;

class WavFormat 
{

	public var compression:Int;
	public var bytesPerSecond:Int;
	public var blockAlign:Int;
	public var data:ByteArray;
	public var bytes: ByteArray;
	public var samples:Array<Sample>;
	public var bits:Int;
	public var rate:Int;
	public var channels:Int;
	public var numSamples:Int;
	
	public function new() { }

	static public function decode(bytes:ByteArray):WavFormat
	{
		return WavDecoder.parse(bytes);
	}
	
	static public function encode(samples:Array<Sample>, channels:Int, bits:Int, rate:Int):ByteArray
	{
		return WavEncoder.encode(samples, channels, bits, rate);
	}
	
	public function toString():String
	{
		return '[WAV Header'
			+ ' compression: '+ compression
			+ ', channels: ' + channels
			+ ', samplingRate: ' + rate
			+ ', bytesPerSecond: ' + bytesPerSecond
			+ ', blockAlign: ' + blockAlign
			+ ', bitsPerSample: ' + bits
			+ ']';
	}
	
}