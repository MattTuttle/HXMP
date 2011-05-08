package hxmp.audio.processor.bitboy.formats.xm;

class XMVolumeCommand 
{
	
	public static inline var NO_COMMAND:UInt = 0x00;
	public static inline var VOLUME:UInt = 0x01;
	
	public static inline var VOLUME_SLIDE_DOWN:UInt = 0x60;
	public static inline var VOLUME_SLIDE_UP:UInt = 0x70;
	public static inline var VOLUME_FINE_DOWN:UInt = 0x80;
	public static inline var VOLUME_FINE_UP:UInt = 0x90;
	public static inline var VIBRATO_SPEED:UInt = 0xa0;
	public static inline var VIBRATO:UInt = 0xb0;
	public static inline var PANNING:UInt = 0xc0;
	public static inline var PANNING_SLIDE_LEFT:UInt = 0xd0;
	public static inline var PANNING_SLIDE_RIGHT:UInt = 0xe0;
	public static inline var TONE_PORTAMENTO:UInt = 0xf0;
	
}