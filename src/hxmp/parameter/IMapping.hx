/**
 * ...
 * @author Matt Tuttle
 */

package hxmp.parameter;

interface IMapping
{
	function map(normalizedValue:Float):Dynamic;
	function mapInverse(value:Dynamic):Float;
}
