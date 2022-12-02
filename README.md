# draw_sprite_bent
```draw_sprite_bent(spr, img_index, x, y, around_x, around_y, bend_angle, segments, xscale, yscale, rot, color, alpha, return_pts)```  
  
Simple vertical bend without having to use bones  
  
Don't recommend using too many segments in too many objects because unfrozen vertexes kill fps  
THE SPRITE REQUIRES TO HAVE "Separate texture page" TICKED!  
  
return_pts = 0   -> return point coordinates of the left side  
return_pts = 0.5 -> return point coordinates in the middle  
return_pts = 1   -> return point coordinates of the right side  
  
The green dot is around_x and around_y attached to the mouse cursor  
Adjusting the bend_angle with mouse wheel  
40 segments  
![image](https://i.postimg.cc/5yn0pCQc/ezgif-2-b48a104d230e.gif)
