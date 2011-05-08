/**
 * ...
 * @author Matt Tuttle
 */

package hxmp.parameter;

class MappingValues implements IMapping
{
	
	private var values:Array<Dynamic>;
	
	public function new(values:Array<Dynamic>)
	{
		this.values = values;
	}
	
	public function map(normalizedValue:Float):Dynamic
	{
		if( normalizedValue == 1 )
			return values[ values.length - 1 ];
		
		return values[ Std.int( normalizedValue * values.length ) ];
	}
	
	public function mapInverse(value:Dynamic):Float
	{
		return values.indexOf( value ) / ( values.length - 1 );
	}
	
}