package hxmp.audio.processor.bitboy.formats.xm;

import flash.errors.Error;

class XMFormatError extends Error
{

	public static inline var FILE_CORRUPT: String = 'Invalid XM file';
	public static inline var NOT_IMPLEMENTED: String = 'A feature has not been implemented yet';
	
	public static inline var MAX_CHANNELS: String = 'Maximum number of channels reached';
	public static inline var MAX_INSTRUMENTS: String = 'Maximum number of instruments reached';
	public static inline var MAX_PATTERNS: String = 'Maximum number of patterns reached';
	public static inline var MAX_LENGTH: String = 'Maximum song length is reached';
	
	public function new(message:String = '', id:Int = 0)
	{
		super(message, id);
	}
	
}