package hxmp.audio.processor.bitboy.formats;

class TriggerBase 
{

	/**
	* The effect that is initialized with this trigger.
	*/		
	public var effect:Int;
	
	/**
	* The parameter for the effect.
	*/	
	public var effectParam:Int;
	
	/**
	* If the trigger has any impact on effects or not.
	*/		
	public var hasEffect:Bool;
	
	/**
	* The period for the trigger.
	*/		
	public var period:Int;


	/**
	 * Creates a new TriggerBase object.
	 * 
	 * Each property of the TriggerBase will be set to its default value.
	 */	
	public function new()
	{
		effect = 0;
		effectParam = 0;
		
		hasEffect = false;
		
		period = 0;
	}
	
	/**
	 * Creates and returns the string representation of the object.
	 * @return The string represenation of the object.
	 */	
	public function toString(): String
	{
		return '[TriggerBase]';
	}
	
}