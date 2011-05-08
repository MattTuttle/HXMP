/**
 * ...
 * @author Matt Tuttle
 */

package hxmp.parameter;

class MappingFloatExponential implements IMapping
{

	private var min:Float;
	private var max:Float;
	
	private var t0:Float;
	private var t1:Float;
	
	public function MappingNumberExponential( min:Float, max:Float )
	{
		this.min = min;
		this.max = max;
		
		t0 = Math.log( max / min );
		t1 = 1.0 / t0;
	}
	
	public function map(normalizedValue:Float):Dynamic
	{
		return min * Math.exp( normalizedValue * t0 );
	}
	
	public function mapInverse(value:Dynamic):Float
	{
		return Math.log( value / min ) * t1;
	}
	
}