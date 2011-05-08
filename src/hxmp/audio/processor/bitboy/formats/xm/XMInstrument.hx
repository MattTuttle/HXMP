/**
 * ...
 * @author Matt Tuttle
 */

package hxmp.audio.processor.bitboy.formats.xm;
import flash.utils.ByteArray;

class XMInstrument 
{

	private static var INSTRUMENT_INDEX_ID:Int = 0;
	
	public var header:XMInstrumentHeader;
	public var sampleHeader:XMSampleHeader;
	public var samples:Array<XMSample>;
	
	//debugging
	public var index:Int;
	
	public function new(stream:ByteArray, index:Int)
	{
		this.index = index;
		parse( stream );
	}
	
	private function parse(stream:ByteArray)
	{
		var p:UInt = stream.position;
		
		header = new XMInstrumentHeader(stream);
		
		if (header.numSamples == 0)
		{
			stream.position = p + header.size;
			return;
		}
		else if (header.numSamples > 1)
		{
			//throw new XMFormatError(XMFormatError.NOT_IMPLEMENTED);
		}
		
		sampleHeader = new XMSampleHeader(stream);
		
		stream.position = p + header.size;
		
		var i:Int;
		samples = new Array<XMSample>();
		for (i in 0...header.numSamples)
			samples.push(new XMSample(stream, sampleHeader.size));
	}
	
	public function toString():String
	{
		return '[XMInstrument header: ' + header.toString() + ', sampleHeader: ' + ( sampleHeader == null ? 'null' : sampleHeader.toString() ) + ', sample: ' + ( samples[0] == null ? 'null' : samples[0].toString() ) + ']';
	}
	
}