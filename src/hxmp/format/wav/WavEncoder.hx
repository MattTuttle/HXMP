/**
 * ...
 * @author Matt Tuttle
 */

package hxmp.format.wav;

import flash.utils.ByteArray;
import flash.utils.Endian;
import hxmp.audio.output.Sample;
import hxmp.audio.output.Audio;

class WavEncoder 
{

	public static function encode(samples:Array<Sample>, channels:Int, bits:Int, rate:Int):ByteArray
	{
		var data: ByteArray = createData( samples, channels, bits, rate );
		
		var bytes: ByteArray = new ByteArray();
		bytes.endian = Endian.LITTLE_ENDIAN;
		
		bytes.writeUTFBytes( 'RIFF' );
		bytes.writeInt( Std.int( data.length + 44 ) );
		bytes.writeUTFBytes( 'WAVE' );
		bytes.writeUTFBytes( 'fmt ' );
		bytes.writeInt( Std.int( 16 ) );
		bytes.writeShort( Std.int( 1 ) );
		bytes.writeShort( channels );
		bytes.writeInt( rate );
		bytes.writeInt( Std.int( rate * channels * ( bits / 8 ) ) );
		bytes.writeShort( Std.int( channels * ( bits / 8 ) ) );
		bytes.writeShort( bits );
		bytes.writeUTFBytes( 'data' );
		bytes.writeInt( data.length );
		bytes.writeBytes( data );
		bytes.position = 0;
		
		return bytes;
	}
	
	public static function createWildHeader(channels:Int, bits:Int, rate:Int):ByteArray
	{
		var bytes: ByteArray = new ByteArray();
		bytes.endian = Endian.LITTLE_ENDIAN;
		
		bytes.writeUTFBytes( 'RIFF' );
		bytes.writeInt( 0 );
		bytes.writeUTFBytes( 'WAVE' );
		bytes.writeUTFBytes( 'fmt ' );
		bytes.writeInt( Std.int( 16 ) );
		bytes.writeShort( Std.int( 1 ) );
		bytes.writeShort( channels );
		bytes.writeInt( rate );
		bytes.writeInt( Std.int( rate * channels * ( bits / 8 ) ) );
		bytes.writeShort( Std.int( channels * ( bits / 8 ) ) );
		bytes.writeShort( bits );
		bytes.writeUTFBytes( 'data' );
		bytes.writeInt( 0 );
		
		bytes.position = 0;
		
		return bytes;
	}
	
	static private function createData(samples:Array<Sample>, channels:Int, bits:Int, rate:Int):ByteArray
	{
		var bytes: ByteArray = new ByteArray();
		bytes.endian = Endian.LITTLE_ENDIAN;
		
		var i:Int;
		var s:Sample;
		var l:Float;
		var r:Float;
		
		var numSamples:Int = samples.length;
		
		switch( channels )
		{
			case Audio.MONO:
				if( bits == Audio.BIT16 )
				{
					for(i in 0...numSamples)
					{
						s = samples[i];
						l = s.left;
						
						if( l < -1 ) bytes.writeShort( -0x7fff );
						else if( l > 1 ) bytes.writeShort( 0x7fff );
						else bytes.writeShort(Std.int(l * 0x7fff));
					}
				}
				else
				{
					for(i in 0...numSamples)
					{
						s = samples[i];
						l = s.left;
						
						if( l < -1 ) bytes.writeByte( 0 );
						else if( l > 1 ) bytes.writeByte( 0xff );
						else bytes.writeByte(Std.int(0x80 + l * 0x7f));
					}
				}
			
			case Audio.STEREO:
				if( bits == Audio.BIT16 )
				{
					for(i in 0...numSamples)
					{
						s = samples[i];
						l = s.left;
						r = s.right;
						
						if( l < -1 ) bytes.writeShort( -0x7fff );
						else if( l > 1 ) bytes.writeShort( 0x7fff );
						else bytes.writeShort(Std.int(l * 0x7fff));
						
						if( r < -1 ) bytes.writeShort( -0x7fff );
						else if( r > 1 ) bytes.writeShort( 0x7fff );
						else bytes.writeShort(Std.int(r * 0x7fff));
					}
				}
				else
				{
					for(i in 0...numSamples)
					{
						s = samples[i];
						l = s.left;
						r = s.right;
						
						if( l < -1 ) bytes.writeByte( 0 );
						else if( l > 1 ) bytes.writeByte( 0xff );
						else bytes.writeByte(Std.int(0x80 + l * 0x7f));
						if( r < -1 ) bytes.writeByte( 0 );
						else if( r > 1 ) bytes.writeByte( 0xff );
						else bytes.writeByte(Std.int(0x80 + r * 0x7f));
					}
				}
		}
		
		return bytes;
	}
	
}