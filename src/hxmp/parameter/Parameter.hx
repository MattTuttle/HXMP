/**
 * ...
 * @author Matt Tuttle
 */

package hxmp.parameter;
import flash.utils.IDataInput;
import flash.utils.IDataOutput;
import flash.utils.IExternalizable;
import flash.errors.Error;

typedef CallbackFunction = Parameter->Dynamic->Dynamic->Void;

class Parameter implements IExternalizable
{

//	{
//		registerClassAlias( 'Parameter', Parameter );
//	}
	
	private var value:Dynamic;
	private var mapping:IMapping;

	private var defaultValue:Dynamic;

	private var changedCallbacks:Array<CallbackFunction>;
	
	/**
	 * Creates a Parameter instance
	 * 
	 * @param mapping The mapping used to map/mapInverse the normalized value
	 * @param value The default values
	 */
	public function new(?mapping:IMapping, ?value:Dynamic)
	{
		this.mapping = mapping;
		this.value = defaultValue = value;
		
		changedCallbacks = new Array<CallbackFunction>();
	}
	
	public function writeExternal(output:IDataOutput)
	{
		output.writeObject(value);
		output.writeObject(defaultValue);
	}
	
	public function readExternal(input:IDataInput)
	{
		setValue( input.readObject() );
		defaultValue = input.readObject();
	}

	/**
	 * Sets the current value of the parameter
	 * 
	 * if changed, inform all callbacks
	 */
	public function setValue(value:Dynamic)
	{
		var oldValue:Dynamic = this.value;
		
		this.value = value;
		
		valueChanged(oldValue);
	}
	
	/**
	 * Returns the current value of the parameter
	 */
	public function getValue():Dynamic
	{
		return value;
	}
	
	/**
	 * Sets the current value of the parameter
	 * by passing a normalized value between 0 and 1
	 * 
	 * if changed, inform all callbacks
	 * 
	 * @param normalizedValue A normalized value between 0 and 1
	 */
	public function setValueNormalized(normalizedValue:Float)
	{
		var oldValue:Dynamic = value;
		
		value = mapping.map(normalizedValue);
		
		valueChanged(oldValue);
	}

	/**
	 * Returns the current normalized value of the parameter
	 * between 0 and 1
	 */
	public function getValueNormalized():Float
	{
		return mapping.mapInverse(value);
	}
	
	/**
	 * Reset value to its initial default value
	 */
	public function reset()
	{
		setValue(defaultValue);
	}
	
	/**
	 * adds a callback function, invoked on value changed
	 * 
	 * @param callback The function, that will be invoked on value changed
	 */
	public function addChangedCallbacks(cbFunc:CallbackFunction)
	{
		changedCallbacks.push(cbFunc);
	}

	/**
	 * removes a callback function
	 * 
	 * @param callback The function, that will be removed
	 */
	public function removeChangedCallbacks(cbFunc:CallbackFunction)
	{
		var index:Int = Lambda.indexOf(changedCallbacks, cbFunc);
		
		if( index > -1 )
			changedCallbacks.splice( index, 1 );
	}
	
	private function valueChanged(oldValue:Dynamic)
	{
		if(oldValue == value)
			return;
		
		try
		{
			var cbFunc:CallbackFunction;
			for (cbFunc in changedCallbacks)
				cbFunc(this, oldValue, value);
		}
		catch(e:Error)
		{
			throw new Error('Make sure callbacks have the following signature: (parameter:Parameter, oldValue:Dynamic, newValue:Dynamic)');
		}
	}
	
}