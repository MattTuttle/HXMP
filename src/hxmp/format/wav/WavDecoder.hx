package hxmp.format.wav;

import flash.utils.ByteArray;
import flash.utils.Endian;
import hxmp.audio.output.Sample;
import hxmp.audio.output.Audio;

class WavDecoder 
{

	public static function parse(bytes:ByteArray):WavFormat
	{
		var wav:WavFormat = new WavFormat();
		var data:ByteArray = new ByteArray();
		
		bytes.position = 0;
		bytes.endian = Endian.LITTLE_ENDIAN;
		
		bytes.readUTFBytes( 4 ); // RIFF
		bytes.readUnsignedInt(); // entire fileLength - 8
		bytes.readUTFBytes( 4 ); // WAVE
		
		var id:String;
		var length:Int;
		var position:Int;
		
		while( bytes.position < bytes.length )
		{
			id = bytes.readUTFBytes( 4 );
			length = bytes.readUnsignedInt();
			
			position = bytes.position;
			
			switch( id )
			{
				case 'fmt ':
				
					wav.compression = bytes.readUnsignedShort();
					wav.channels = bytes.readUnsignedShort();
					wav.rate = bytes.readUnsignedInt();
					wav.bytesPerSecond = bytes.readUnsignedInt();
					wav.blockAlign = bytes.readUnsignedShort();
					wav.bits = bytes.readUnsignedShort();
					break;
				
				case 'data':
					data.endian = Endian.LITTLE_ENDIAN;
					data.writeBytes( bytes, position, length );
					data.position = 0;
					wav.data = data;
					bytes.position = position + length;
					break;
				
				default:
				
					bytes.position = position + length;
					break;
			}
		}
		
		//-- compute samplenum
		wav.numSamples = data.length;
		if( wav.channels == 2 )
			wav.numSamples >>= 1;
		if( wav.bits == 16 )
			wav.numSamples >>= 1;
		
		//-- create samples for audio engine
		wav.samples = createSamples( wav );
		
		return wav;
	}
	
	static private function createSamples(wav:WavFormat):Array<Sample>
	{
		var sampleCount:Int = wav.numSamples;
		var channels:Int = wav.channels;
		var bits:Int = wav.bits;
		var data:ByteArray = wav.data;
		
		var samples:Array<Sample> = new Array<Sample>();
		var i:Int;
		
		var value:Float;
		
		if( channels == Audio.STEREO )
		{
			if( bits == Audio.BIT16 )
			{
				for (i in 0...sampleCount)
				{
					samples[i] = new Sample( data.readShort() / 0x7fff, data.readShort() / 0x7fff );
				}
			}
			else
			{
				for (i in 0...sampleCount)
				{
					samples[i] = new Sample( data.readUnsignedByte() / 0x80 - 1, data.readUnsignedByte() / 0x80 - 1 );
				}
			}
		}
		else if( channels == Audio.MONO )
		{
			if( bits == Audio.BIT16 )
			{
				for (i in 0...sampleCount)
				{
					value = data.readShort() / 0x7fff;
					
					samples[i] = new Sample( value, value );
				}
			}
			else
			{
				for (i in 0...sampleCount)
				{
					value = data.readUnsignedByte() / 0x80 - 1;
					
					samples[i] = new Sample( value, value );
				}
			}
		}
		
		return samples;
	}
	
}