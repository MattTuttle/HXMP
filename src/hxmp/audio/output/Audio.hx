package hxmp.audio.output;

import flash.errors.Error;

class Audio 
{
	public static inline var MONO:Int = 1;
	public static inline var STEREO:Int = 2;
	
	public static inline var BIT8:Int = 8;
	public static inline var BIT16:Int = 16;
	
	public static inline var RATE44100:Int = 44100;
	public static inline var RATE22050:Int = 22050;
	public static inline var RATE11025:Int = 11025;
	public static inline var RATE5512:Int = 5512;

	/**
	 * Checks all reasonable audio properties
	 * @throws Error thrown, if any property has not valid value
	 * 
	 * @param channels Mono(1) or Stereo(2)
	 * @param bits 8bit(8) or 16bit(16)
	 * @param rate SamplingRate 5512Hz, 11025Hz, 22050Hz, 44100Hz
	 */
	public static function checkAll(channels:Int, bits:Int, rate:Int)
	{
		checkChannels( channels );
		checkBits( bits );
		checkRate( rate );
	}
	
	/**
	 * Checks if the passed number of channels if valid
	 * @throws Error thrown, if not Mono(1) or Stereo(2)
	 * 
	 * @param channels Mono(1) or Stereo(2)
	 */
	public static function checkChannels(channels:Int)
	{
		switch(channels)
		{
			case MONO:
			case STEREO:
				return;
			
			default:
				throw new Error('Only mono or stereo is supported.');
		}
	}

	/**
	 * Checks if the passed number of bits if valid
	 * @throws Error thrown, if not 8bit(8) or 16bit(16)
	 * 
	 * @param bits 8bit(8) or 16bit(16)
	 */
	public static function checkBits(bits:Int)
	{
		switch( bits )
		{
			case BIT8:
			case BIT16:
				return;
			
			default:
				throw new Error( 'Only 8 and 16 bit is supported.' );
		}
	}

	/**
	 * Checks if the passed number of bits if valid
	 * @throws Error thrown, if not 5512Hz, 11025Hz, 22050Hz, 44100Hz
	 * 
	 * @param rate SamplingRate 5512Hz, 11025Hz, 22050Hz, 44100Hz
	 */
	public static function checkRate(rate:Int)
	{
		switch( rate )
		{
			case RATE44100:
			case RATE22050:
			case RATE11025:
			case RATE5512:
				return;
			
			default:
				throw new Error(Std.string(rate) + 'is not supported.');
		}
	}

}