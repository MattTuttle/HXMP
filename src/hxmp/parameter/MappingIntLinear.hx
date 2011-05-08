/**
 * ...
 * @author Matt Tuttle
 */

package hxmp.parameter;

class MappingIntLinear implements IMapping
{

	private var min:Float;
	private var max:Float;

	public function new(?min:Int, ?max:Int)
	{
		this.min = (min == null) ? 0 : min;
		this.max = (max == null) ? 1 : max;
	}

	public function map(normalizedValue:Float):Dynamic
	{
		return Std.int( min + normalizedValue * ( max - min ) );
	}

	public function mapInverse(value:Dynamic):Float
	{
		return ( value - min ) / ( max - min );
	}
	
}