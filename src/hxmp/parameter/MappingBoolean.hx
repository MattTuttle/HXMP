package hxmp.parameter;

class MappingBoolean implements IMapping
{
	
	public function new()
	{
		
	}

	public function map(normalizedValue:Float):Dynamic
	{
		return normalizedValue > .5;
	}
	
	public function mapInverse(value:Dynamic):Float
	{
		return value ? 1 : 0;
	}
	
}