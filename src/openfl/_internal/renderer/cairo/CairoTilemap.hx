package openfl._internal.renderer.cairo;


import lime.graphics.cairo.CairoFilter;
import lime.graphics.cairo.CairoFormat;
import lime.graphics.cairo.CairoPattern;
import lime.graphics.cairo.CairoSurface;
import lime.math.Matrix3;
import openfl.display.BitmapData;
import openfl.display.CairoRenderer;
import openfl.display.TileGroup;
import openfl.display.Tilemap;
import openfl.display.Tileset;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end

@:access(lime.graphics.ImageBuffer)
@:access(openfl.display.BitmapData)
@:access(openfl.display.Tile)
@:access(openfl.display.TileGroup)
@:access(openfl.display.Tilemap)
@:access(openfl.display.Tileset)
@:access(openfl.geom.Matrix)
@:access(openfl.geom.Rectangle)


class CairoTilemap {
	
	
	public static function render (tilemap:Tilemap, renderer:CairoRenderer):Void {
		
		if (!tilemap.__renderable || tilemap.__group.__tiles.length == 0 || tilemap.__worldAlpha <= 0) return;
		
		renderer.__setBlendMode (tilemap.__worldBlendMode);
		renderer.__pushMaskObject (tilemap);
		
		var rect = Rectangle.__pool.get ();
		rect.setTo (0, 0, tilemap.__width, tilemap.__height);
		renderer.__pushMaskRect (rect, tilemap.__renderTransform);
		
		renderTileGroup (tilemap.__group, renderer, tilemap.__renderTransform, tilemap.__tileset, (renderer.__allowSmoothing && tilemap.smoothing), tilemap.tileAlphaEnabled, tilemap.__worldAlpha, null, null, null, rect, new Matrix3 ());
		
		renderer.__popMaskRect ();
		renderer.__popMaskObject (tilemap);
		
		Rectangle.__pool.release (rect);
		
	}
	
	
	private static function renderTileGroup (group:TileGroup, renderer:CairoRenderer, parentTransform:Matrix, defaultTileset:Tileset, smooth:Bool, alphaEnabled:Bool, worldAlpha:Float, cacheBitmapData:BitmapData, surface:CairoSurface, pattern:CairoPattern, rect:Rectangle, matrix:Matrix3):Void {
		
		var cairo = renderer.cairo;
		var roundPixels = renderer.__roundPixels;
		
		var tileTransform = Matrix.__pool.get ();
		
		var tiles = group.__tiles;
		var length = group.__length;
		
		var tile, tileset, alpha, visible, id, tileData, tileRect, bitmapData;
		
		for (tile in tiles) {
			
			tileTransform.setTo (1, 0, 0, 1, -tile.originX, -tile.originY);
			tileTransform.concat (tile.matrix);
			tileTransform.concat (parentTransform);
			
			tileset = tile.tileset != null ? tile.tileset : defaultTileset;
			
			alpha = tile.alpha * worldAlpha;
			visible = tile.visible;
			if (!visible || alpha <= 0) continue;
			
			if (!alphaEnabled) alpha = 1;
			
			if (tile.__length > 0) {
				
				renderTileGroup (cast tile, renderer, tileTransform, tileset, smooth, alphaEnabled, alpha, cacheBitmapData, surface, pattern, rect, matrix);
				
			} else {
				
				if (tileset == null) continue;
				
				id = tile.id;
				
				if (id == -1) {
					
					tileRect = tile.rect;
					if (tileRect == null || tileRect.width <= 0 || tileRect.height <= 0) continue;
					
				} else {
					
					tileData = tileset.__data[id];
					if (tileData == null) continue;
					
					rect.setTo (tileData.x, tileData.y, tileData.width, tileData.height);
					tileRect = rect;
					
				}
				
				bitmapData = tileset.__bitmapData;
				if (bitmapData == null) continue;
				
				if (bitmapData != cacheBitmapData) {
					
					surface = bitmapData.getSurface ();
					pattern = CairoPattern.createForSurface (surface);
					pattern.filter = smooth ? CairoFilter.GOOD : CairoFilter.NEAREST;
					
					cairo.source = pattern;
					cacheBitmapData = bitmapData;
					
				}
				
				renderer.applyMatrix (tileTransform, cairo);
				
				matrix.tx = tileRect.x;
				matrix.ty = tileRect.y;
				pattern.matrix = matrix;
				cairo.source = pattern;
				
				cairo.save ();
				
				cairo.newPath ();
				cairo.rectangle (0, 0, tileRect.width, tileRect.height);
				cairo.clip ();
				
				if (alpha == 1) {
					
					cairo.paint ();
					
				} else {
					
					cairo.paintWithAlpha (alpha);
					
				}
				
				cairo.restore ();
				
			}
			
		}
		
		Matrix.__pool.release (tileTransform);
		
	}
	
	
}
