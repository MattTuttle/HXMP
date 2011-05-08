/**
 * ...
 * @author Matt Tuttle
 */

package hxmp.audio.processor.bitboy.formats.xm;
import flash.utils.ByteArray;

class XMInstrumentHeader 
{

	public var size:UInt;
	public var name:String;
	public var type:UInt;
	public var numSamples:UInt;
	
	public function new(stream:ByteArray)
	{
		parse(stream);
	}
	
	private function parse(stream:ByteArray)
	{
		size = stream.readUnsignedInt();
		name = stream.readMultiByte(22, XMFormat.ENCODING);
		type = stream.readUnsignedByte();
		numSamples = stream.readUnsignedShort();
	}
	
	public function toString():String
	{
		return '[XMInstrumentHeader size: ' + size + ', name: ' + name + ', type: ' + Std.string(type) + ', numSamples: ' + numSamples + ']';
	}
	
}