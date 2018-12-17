package openfl._internal.utils;


import openfl.display.DisplayObject;
import openfl.display.InteractiveObject;

#if lime
import lime.ui.Touch;
import lime.utils.ObjectPool;
#end

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end


class TouchData {
	
	
	#if lime
	public static var __pool = new ObjectPool<TouchData> (function () return new TouchData (), function (data) data.reset ());
	#end
	
	public var rollOutStack:Array<DisplayObject>;
	public var touch:#if lime Touch #else Dynamic #end;
	public var touchDownTarget:InteractiveObject;
	public var touchOverTarget:InteractiveObject;
	
	
	public function new () {
		
		rollOutStack = [];
		
	}
	
	
	public function reset ():Void {
		
		touch = null;
		touchDownTarget = null;
		touchOverTarget = null;
		
		rollOutStack.splice (0, rollOutStack.length);
		
	}
	
	
}