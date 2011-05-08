/**
 * ...
 * @author Matt Tuttle
 */

package hxmp.audio.output;

class Sample 
{
	
	/**
	 * The left amplitude of the Sample
	 */
	public var left:Float;
	/**
	 * The right amplitude of the Sample
	 */
	public var right:Float;

	/**
	 * Creates a Sample instance
	 * 
	 * @param left The left amplitude of the Sample
	 * @param right The right amplitude of the Sample
	 */
	public function new(left:Float = 0.0, right:Float = 0.0)
	{
		this.left = left;
		this.right = right;
	}
	
	/**
	 * Returns a clone of the current Sample
	 */
	public function clone():Sample
	{
		return new Sample(left, right);
	}
	
	public function toString():String
	{
		return '{ left: ' + left + ' right: ' + right + ' }';
	}
	
}