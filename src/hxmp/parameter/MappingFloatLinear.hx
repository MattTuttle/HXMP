/**
 * ...
 * @author Matt Tuttle
 */

package hxmp.parameter;

class MappingFloatLinear implements IMapping
{

	private var min:Float;
	private var max:Float;
	
	public function new(?min:Float, ?max:Float)
	{
		this.min = (min == null) ? 0 : min;
		this.max = (max == null) ? 1 : max;
	}
	
	public function map(normalizedValue:Float):Dynamic
	{
		return min + normalizedValue * ( max - min );
	}
	
	public function mapInverse(value:Dynamic):Float
	{
		return ( value - min ) / ( max - min );
	}
	
}