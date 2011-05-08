package hxmp.audio.processor.bitboy.formats.mod;

import flash.errors.Error;
import flash.utils.ByteArray;
import flash.utils.Endian;
import hxmp.audio.output.Sample;
import hxmp.audio.processor.bitboy.channel.ChannelBase;
import hxmp.audio.processor.bitboy.formats.TriggerBase;
import hxmp.audio.processor.bitboy.BitBoy;
import hxmp.audio.processor.bitboy.channel.ModChannel;
import hxmp.audio.processor.bitboy.formats.FormatBase;

class ModFormat extends FormatBase
{

	static public function decode( stream: ByteArray ): ModFormat
	{
		return new ModFormat( stream );
	}
	
	// ModFormat specific
	public var modSamples:Array<ModSample>;

	//-- MOD format
	public var format: String;
		
	//-- define some positions in the file
	private static inline var P_FORMAT:Int = 0x438;
	private static inline var P_LENGTH:Int = 0x3b6;
	private static inline var P_SEQUENCE:Int = 0x3b8;
	private static inline var P_PATTERNS:Int = 0x43c;
	
	public function new(stream:ByteArray)
	{
		super(stream);
		
		//modSamples = new Array(32);
		modSamples = new Array<ModSample>();
		format = '';

		numChannels = 4;
				
		restartPosition = 0;

		defaultBpm = 125;
		defaultSpeed = 6;
				
		parse( stream );
	}
	
	override public function getChannels(bitboy:BitBoy):Array<ChannelBase>
	{
		var array:Array<ChannelBase> = new Array<ChannelBase>();
		array.push(new ModChannel( bitboy, 0, -1 ));
		array.push(new ModChannel( bitboy, 1,  1 ));
		array.push(new ModChannel( bitboy, 2,  1 ));
		array.push(new ModChannel( bitboy, 3, -1 ));
		return array;
	}
	
	override private function parse(stream: ByteArray)
	{
		stream.endian = Endian.LITTLE_ENDIAN;
		stream.position = P_FORMAT;
		
		var patternNum:UInt = 0;
		
		//-- mod format
		format = String.fromCharCode( stream.readByte() ) + String.fromCharCode( stream.readByte() ) +
				 String.fromCharCode( stream.readByte() ) + String.fromCharCode( stream.readByte() );
		
		if ( format.toLowerCase() != 'm.k.' )
			throw new Error( 'Unsupported MOD format' );
		
		 var i:Int;
		
		//-- title
		title = '';
		stream.position = 0;
		for (i in 0...20)
		{
			var char:UInt = stream.readUnsignedByte();			
			if ( char == 0 )
				break;	
			title += String.fromCharCode( char );
		}
		
		//-- sequence length
		stream.position = P_LENGTH;
		length = stream.readUnsignedByte();
		
		//-- samples
		var bytes: ByteArray = new ByteArray();
		for (i in 1...32)
		{  		
			stream.position = ( i - 1 ) * 0x1e + 0x14;
			bytes.position = 0;
			
			stream.readBytes( bytes, 0, 30 );	
			
			modSamples[i] = new ModSample( bytes );
		}
		
		//-- sequence
		stream.position = P_SEQUENCE;
		// sequence = new Array(length);
		sequence = new Array<UInt>();
			
		for (i in 0...length)
		{
			sequence[i] = stream.readUnsignedByte();
			
			if (sequence[i] > patternNum)
				patternNum = sequence[ i ];
		}
		
		
		numPatterns = patternNum;
	
		//-- patterns
		for (i in 0...patternNum + 1)
		{
			//-- 4bytes * 4channels * 64rows = 0x400bytes
			stream.position = P_PATTERNS + i * 0x400;
			
			//patterns[i] = new Array(64);
			patterns[i] = new Array<Array<TriggerBase>>();
			
			var j:Int, k:Int;
			for (j in 0...64)
			{
				//patterns[i][j] = new Array(4);
				patterns[i][j] = new Array<TriggerBase>();
				for (k in 0...4)
				{
					// patterns[i][j][k] = new ModTrigger(stream, modSamples);
					patterns[i][j][k] = new ModTrigger(stream, modSamples);
					
					//if( k == 0 )
					//{
					//	trace( j, patterns[ i ][ j ][ k ] );
					//}
				}
			}
		}
		
		//-- waveforms
		var sample:ModSample;
		for (i in 1...32)
		{
			sample = modSamples[i];
			sample.loadWaveform(stream);
		}
		
		//-- credits
		var modSample: ModSample;

		for(i in 1...modSamples.length)
		{
			modSample = modSamples[i];
			
			if( modSample.title != '' )
			{
				credits.push( modSample.title );
			}
		}
	}
	
}