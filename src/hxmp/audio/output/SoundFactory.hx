package hxmp.audio.output;

import flash.display.Loader;
import flash.events.Event;
import flash.utils.ByteArray;
import flash.utils.Endian;
import flash.media.Sound;

typedef CompleteFunction = Event->Void;

class SoundFactory 
{
	
	/**
	 * Creates a flash.media.Sound object from dynamic audio material
	 * 
	 * @param samples An Array of Samples (de.popforge.audio.output.Sample)
	 * @param channels Mono(1) or Stereo(2)
	 * @param bits 8bit(8) or 16bit(16)
	 * @param rate SamplingRate 5512Hz, 11025Hz, 22050Hz, 44100Hz
	 * @param onComplete Function, that will be called after the Sound object is created. The signature must accept the Sound object as a parameter!
	 * 
	 * @see http://livedocs.adobe.com/flex/2/langref/flash/media/Sound.html flash.media.Sound
	 */
	static public function fromArray(samples:Array<Sample>, channels:UInt, bits:UInt, rate:UInt, onComplete:CompleteFunction)
	{
		var bytes:ByteArray = new ByteArray();
		bytes.endian = Endian.LITTLE_ENDIAN;
		
		var i:Int;
		var s:Sample;
		var l:Float;
		var r:Float;
		
		var _numSamples:Int = samples.length;
		
		switch(channels)
		{
			case Audio.MONO:
				if(bits == Audio.BIT16)
				{
					for(i in 0..._numSamples)
					{
						s = samples[i];
						l = s.left;
						
						if(l < -1) bytes.writeShort(-0x7fff);
						else if(l > 1) bytes.writeShort(0x7fff);
						else bytes.writeShort(Std.int(l * 0x7fff));
						
						s.left = s.right = 0;
					}
				}
				else
				{
					for(i in 0..._numSamples)
					{
						s = samples[i];
						l = s.left;
						
						if(l < -1) bytes.writeByte(0);
						else if(l > 1) bytes.writeByte(0xff);
						else bytes.writeByte(Std.int(0x80 + l * 0x7f));
						
						s.left = s.right = 0;
					}
				}
				
			case Audio.STEREO:
				if(bits == Audio.BIT16)
				{
					for(i in 0..._numSamples)
					{
						s = samples[i];
						l = s.left;
						r = s.right;
						
						if(l < -1) bytes.writeShort(-0x7fff);
						else if(l > 1) bytes.writeShort(0x7fff);
						else bytes.writeShort(Std.int(l * 0x7fff));
						
						if(r < -1) bytes.writeShort(-0x7fff);
						else if(r > 1) bytes.writeShort(0x7fff);
						else bytes.writeShort(Std.int(r * 0x7fff));
						
						s.left = s.right = 0;
					}
				}
				else
				{
					for(i in 0..._numSamples)
					{
						s = samples[i];
						l = s.left;
						r = s.right;
						
						if(l < -1) bytes.writeByte(0);
						else if(l > 1) bytes.writeByte(0xff);
						else bytes.writeByte(Std.int(0x80 + l * 0x7f));
						if(r < -1) bytes.writeByte(0);
						else if(r > 1) bytes.writeByte(0xff);
						else bytes.writeByte(Std.int(0x80 + r * 0x7f));
						
						s.left = s.right = 0;
					}
				}
		}
		
		SoundFactory.fromByteArray(bytes, channels, bits, rate, onComplete);
	}

	/**
	 * Creates a flash.media.Sound object from dynamic audio material
	 * 
	 * @param samples A uncompressed PCM ByteArray
	 * @param channels Mono(1) or Stereo(2)
	 * @param bits 8bit(8) or 16bit(16)
	 * @param rate SamplingRate 5512Hz, 11025Hz, 22050Hz, 44100Hz
	 * @param onComplete Function, that will be called after the Sound object is created. The signature must accept the Sound object as a parameter!
	 * 
	 * @see http://livedocs.adobe.com/flex/2/langref/flash/media/Sound.html flash.media.Sound
	 */
	static public function fromByteArray(bytes:ByteArray, channels:UInt, bits:UInt, rate:UInt, onComplete:CompleteFunction)
	{
		Audio.checkAll(channels, bits, rate);
		
		//-- get naked swf bytearray
		var swf:ByteArray = new SWF();

		swf.endian = Endian.LITTLE_ENDIAN;
		swf.position = swf.length;

		//-- write define sound tag header
		swf.writeShort(0x3bf);
		swf.writeUnsignedInt(bytes.length + 7);

		//-- assemble audio property byte (uncompressed little endian)
		var byte2:UInt = 3 << 4;

		switch(rate)
		{
			case 44100: byte2 |= 0xc;
			case 22050: byte2 |= 0x8;
			case 11025:	byte2 |= 0x4;
		}

		var numSamples:Int = bytes.length;
		
		if(channels == 2)
		{
			byte2 |= 1;
			numSamples >>= 1;
		}
		
		if(bits == 16)
		{
			byte2 |= 2;
			numSamples >>= 1;
		}

		//-- write define sound tag
		swf.writeShort(1);
		swf.writeByte(byte2);
		swf.writeUnsignedInt(numSamples);
		swf.writeBytes(bytes);

		//-- write eof tag in swf stream
		swf.writeShort(1 << 6);
		
		//-- overwrite swf length
		swf.position = 4;
		swf.writeUnsignedInt(swf.length);
		swf.position = 0;
		
		var onSWFLoaded:CompleteFunction = function(event:Event)
		{
//			onComplete(Sound(new (loader.contentLoaderInfo.applicationDomain.getDefinition('SoundItem') as Class)()));
		};
		
		var loader:Loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onSWFLoaded);
		loader.loadBytes(swf);
	}
	
}