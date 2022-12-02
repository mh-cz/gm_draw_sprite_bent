global.BEND_SPR_DATA = [];
	
vertex_format_begin();
vertex_format_add_position();
vertex_format_add_colour();
vertex_format_add_texcoord();
global.BEND_SPR_DATA[0] = vertex_format_end(); // vf
global.BEND_SPR_DATA[1] = vertex_create_buffer(); // b

function draw_sprite_bent(spr, img_index, x, y, around_x, around_y, bend_angle, segments, xscale = 1, yscale = 1, rot = 0, color = c_white, alpha = 1, return_pts = -1) {
	
	var spr_w = sprite_get_width(spr);
	var spr_h = sprite_get_height(spr);
	var xoff = sprite_get_xoffset(spr) * xscale;
	var yoff = sprite_get_yoffset(spr) * yscale;
	
	segments = max(4, ceil(segments));
	var step = spr_h / segments;
	var angle_step = bend_angle / segments;
	
	// split the sprite into triangles with UVs
	
	var uv = array_create(2 + ceil((spr_h + 0.1) / step));
	var ci = 0;
	
	uv[ci++] = [1, 0];
	
	var right = false;
	for(var h = 0; h < spr_h + 0.1; h += step) {
		uv[ci++] = [real(right), h/spr_h];
		right = !right;
	}
	uv[ci++] = [real(right), 1];
	
	// rotate the triangles around pivot and save the new coordinates
	
	var counter = 0;
	var angl = 0;
	var uvlen = array_length(uv);
	var coords = array_create(uvlen);
	ci = 0;
	
	var u, v, pivot_x, pivot_y, pdr, pds, xx, yy;
	
	for(var i = uvlen-1; i > -1; i--) {
		
		u = uv[i][0];
		v = uv[i][1];
		
		pivot_x = (around_x - (x - xoff)) / xscale;
		pivot_y = (around_y - (y - yoff)) / yscale;
		
		pdr = point_direction(pivot_x, pivot_y, u * spr_w, v * spr_h);
		pds = point_distance(pivot_x, pivot_y, u * spr_w, v * spr_h);
		xx = pivot_x + lengthdir_x(pds, pdr + angl);
		yy = pivot_y + lengthdir_y(pds, pdr + angl);
		
		coords[ci++] = [ xx * xscale, yy * yscale, (counter == 1), u, v ];
		
		if counter++ == 2 {
			counter = 0;
			if i == 0 break;
			i += 2;
			angl += angle_step;
		}
	}
	
	var vf = global.BEND_SPR_DATA[0];
	var b = global.BEND_SPR_DATA[1];
	
	vertex_begin(b, vf);
	
	var final_pts = return_pts != -1 ? array_create(floor(segments/2)) : [];
	var ptsi = 0;
	var prev_px = undefined;
	var prev_py = undefined;
	var this_px = 0;
	var this_py = 0;
	
	var c_prev, c_next, c_curr;
	
	for(var i = 0; i < ci; i++) {
		
		// connect corners so the image can stretch
		
		c_curr = coords[i];
		
		if i == clamp(i, 2, ci-3) {
			
			c_prev = coords[i-2];
			c_next = coords[i+2];
			
			if c_prev[2] {
				c_curr[0] = c_prev[0];
				c_curr[1] = c_prev[1];
			}
			if c_next[2] {
				c_curr[0] = c_next[0];
				c_curr[1] = c_next[1];
			}
		}
		
		// apply rotation and draw
		
		xx = c_curr[0] - xoff;
		yy = c_curr[1] - yoff;
		
		if rot != 0 {
			pdr = point_direction(0, 0, xx, yy);
			pds = point_distance(0, 0, xx, yy);
			xx = lengthdir_x(pds, pdr + rot);
			yy = lengthdir_y(pds, pdr + rot);
		}
		
		vertex_position(b, x + xx, y + yy);
		vertex_colour(b, color, alpha);
		vertex_texcoord(b, c_curr[3], c_curr[4]);
		
		if return_pts != -1 and i % 3 == 1 {
			
			if prev_px == undefined {
				prev_px = x + xx;
				prev_py = y + yy;
			}
			else {
				this_px = x + xx;
				this_py = y + yy;
				
			    var ds = point_distance(this_px, this_py, prev_px, prev_py) * return_pts;
			    var dr = point_direction(this_px, this_py, prev_px, prev_py);
    
			    final_pts[ptsi++] = [ prev_px + lengthdir_x(ds, dr), prev_py + lengthdir_y(ds, dr) ];
				
				prev_px = this_px;
				prev_py = this_py;
			}
		}
	}
	
	vertex_end(b);
	vertex_submit(b, pr_trianglelist, sprite_get_texture(spr, img_index));
	
	return final_pts;
}
