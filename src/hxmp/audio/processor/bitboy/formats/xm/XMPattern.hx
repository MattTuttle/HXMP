/**
 * ...
 * @author Matt Tuttle
 */

package hxmp.audio.processor.bitboy.formats.xm;
import flash.utils.ByteArray;

class XMPattern
{

	private var numRows:UInt;

	private var headerLength:UInt;
	private var packingType:UInt;

	private var packedDataSize:UInt;
	private var dataOffset:UInt;
	
	public var rows:Array<Array<XMTrigger>>;
	
	public function new(stream:ByteArray)
	{
		parse(stream);
	}
	
	public var length(getLength, null):Int;
	private function getLength():Int
	{
		return rows.length;
	}
	
	public function row(index:Int):Array<XMTrigger>
	{
		return rows[index];
	}

	private function parse(stream:ByteArray)
	{
		headerLength = stream.readUnsignedInt();
		packingType = stream.readUnsignedByte();
		
		numRows = stream.readUnsignedShort();
		// rows = new Array(numRows);
		rows = new Array<Array<XMTrigger>>();
		
		packedDataSize = stream.readUnsignedShort();
		dataOffset = stream.position;
		
		//-- skip data for now
		stream.position += packedDataSize;
	}
	
	public function parseData(stream:ByteArray, numChannels:UInt, instruments:Array<XMInstrument>)
	{
		var i:Int, j:Int;
		
		stream.position = dataOffset;
		
		if (packedDataSize <= 0)
		{
			var emptyElement:ByteArray = new ByteArray();
			
			emptyElement.writeByte(0x81);//use packed note to read 0x80
			emptyElement.writeByte(0x80);
			
			for (i in 0...numRows)
			{
				// rows[i] = new Array(numChannels);
				rows[i] = new Array<XMTrigger>();
				
				for (j in 0...numChannels)
				{
					emptyElement.position = 0;
					rows[i][j] = new XMTrigger(emptyElement, instruments);
				}
			}
		}
		else
		{
			for (i in 0...numRows)
			{
				// rows[i] = new Array(numChannels);
				rows[i] = new Array<XMTrigger>();
				
				for (j in 0...numChannels)
				{
					rows[i][j] = new XMTrigger(stream, instruments);
				}
			}
		}
	}
	
	public function toString():String
	{
		return '[XMPattern headerLength:' + headerLength + ', packingType:' + packingType + ', numRows:' + numRows + ', packedDataSize:' + packedDataSize + ']';
	}
	
	public function toASCII():String
	{
		if (packedDataSize == 0)
			return '(empty)\n';
			
		var patternString:String = '';
		var numChannels:UInt = rows[0].length;
		var row:Array<XMTrigger>;
		var line:String;
		
		var i:Int, j:Int;
		for (i in 0...numRows)
		{
			row = rows[i];
			
			line = pad(Std.string(i)) + ':';
			
			for (j in 0...numChannels)
			{
				if (j != 0) line += ' | ';
				
				var trigger:XMTrigger = row[ j ];
				
				if (trigger.note == 0xff)
					line += '==';
				else
					line += (trigger.note == 0 ? '..' :pad(Std.string(trigger.note)));
				
				line += ' ' + pad((trigger.instrument == null ? '..' : Std.string(trigger.instrument.index)));
				
				
				if (!trigger.hasVolume)
				{
					line += ' ...';
				}
				else
				{
					line += ' ';
					
					switch (trigger.volumeCommand)
					{
						case XMVolumeCommand.PANNING:				line += 'p'; break;
						case XMVolumeCommand.PANNING_SLIDE_LEFT:	line += 'l'; break;
						case XMVolumeCommand.PANNING_SLIDE_RIGHT:	line += 'r'; break;
						case XMVolumeCommand.TONE_PORTAMENTO:		line += 'g'; break;
						case XMVolumeCommand.VIBRATO:				line += 'v'; break;
						case XMVolumeCommand.VIBRATO_SPEED:			line += 'h'; break;
						case XMVolumeCommand.VOLUME:				line += 'v'; break;
						case XMVolumeCommand.VOLUME_FINE_DOWN:		line += 'b'; break;
						case XMVolumeCommand.VOLUME_FINE_UP:		line += 'a'; break;
						case XMVolumeCommand.VOLUME_SLIDE_DOWN:		line += 'd'; break;
						case XMVolumeCommand.VOLUME_SLIDE_UP:		line += 'c'; break;
						
						case XMVolumeCommand.NO_COMMAND:
						default:									line += '.'; break;
					}
					
					line += pad(Std.string(trigger.volume));
				}
				
				if (trigger.hasEffect)
				{
					line += ' ' + (Std.string(trigger.effect).toUpperCase());
					line += pad((Std.string(trigger.effectParam).toUpperCase()));
				}
				else
					line += ' ...';
			}
			
			patternString += line + '\n';
		}
		
		return patternString;
	}
	
	private function pad(input:String, toLength:UInt = 2, paddingChar:String = '0'):String
	{
		while (input.length < Std.int(toLength))
			input = paddingChar + input;
		
		return input;
	}
	
}