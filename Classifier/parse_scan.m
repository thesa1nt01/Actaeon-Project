function vv_points = parse_scan(laser_rth,r_pose)

vv_points = [];

    SEP_THRESH = 12.5; %cm
    MIN_NUM_OF_RANGES = 3; %Minimum number of ranges needed to produce points
    vect_ranges = zeros(length(laser_rth),2);
    vect_points = zeros(length(laser_rth),2);
    
    for ndx = 1:(length(laser_rth)-1)
      % If the ranges are similar to each other then they are candidates
      if abs(laser_rth(ndx,1) - laser_rth(ndx + 1,1)) < SEP_THRESH
	  % If this is the first time anything has been added, add both
    	  if sum(vect_ranges(:,1)) == 0
              vect_ranges(ndx,1) = laser_rth(ndx,1);
              vect_ranges(ndx,2) = laser_rth(ndx,2);
          end	  
          vect_ranges(ndx+1,1) = laser_rth(ndx+1,1);
          vect_ranges(ndx+1,2) = laser_rth(ndx+1,2);
         
	
      % If we are not adding ranges and there are more than two candidate ranges,
      % then add them to the points vector
      elseif sum(vect_ranges(:,1)~=0) >= MIN_NUM_OF_RANGES
    	for ndx_vr = 1:length(vect_ranges)
            if vect_ranges(ndx_vr,1) ~=0
                x = vect_ranges(ndx_vr,1)*cos(vect_ranges(ndx_vr,2)) + r_pose(1);
                y = vect_ranges(ndx_vr,1)*sin(vect_ranges(ndx_vr,2)) + r_pose(2);
                vect_points(ndx_vr,1) = x;
                vect_points(ndx_vr,2) = y;
            end
        end
    	vv_points = [vv_points, vect_points];
        vect_ranges = zeros(length(laser_rth),2);
        vect_points = zeros(length(laser_rth),2);
      
      % If we are not adding ranges, and the current range vector contains too few candidates
      else
        vect_ranges = zeros(length(laser_rth),2);
      end
     
      % Check the special case of an object being split by the beginning and end of the scan
      if ndx == (length(laser_rth) - 1)
        if abs(laser_rth(ndx + 1,1) - laser_rth(1,1)) < SEP_THRESH
        
        % Add the last range  
        vect_ranges(ndx + 1,1) = laser_rth(ndx + 1,1);
        vect_ranges(ndx + 1,2) = laser_rth(ndx + 1,2);
        % Add the first range
        vect_ranges(1,1) = laser_rth(1,1);
        vect_ranges(1,2) = laser_rth(1,2);
	    for iter = 1:(length(laser_rth) - 1)
           if abs(laser_rth(iter,1) - laser_rth(iter + 1,1)) < SEP_THRESH 	
              vect_ranges(iter+1,1) = laser_rth(iter+1,1);
              vect_ranges(iter+1,2) = laser_rth(iter+1,2);
           
	      % If we are not adding ranges and there are more than two candidate ranges,
	      % then add them to the points vector
           elseif sum(vect_ranges(:,1)~=0) >= MIN_NUM_OF_RANGES
    		for ndx_vr = 1:length(vect_ranges)
                if vect_ranges(ndx_vr,1) ~=0
                    x = vect_ranges(ndx_vr,1)*cos(vect_ranges(ndx_vr,2)) + r_pose(1);
                    y = vect_ranges(ndx_vr,1)*sin(vect_ranges(ndx_vr,2)) + r_pose(2);
                    vect_points(ndx_vr,1) = x;
                    vect_points(ndx_vr,2) = y;
                end
            end
            vv_points = [vv_points, vect_points];
            vect_ranges = zeros(length(laser_rth),2);
            vect_points = zeros(length(laser_rth),2);
              
	      % If we are not adding ranges, and the current range vector contains too few candidates
           else
            break;
           end
        end
    end
      end
    end

%%% If the last column contains elements from the beginning of the scan, it
%%% must over lap, so remove the first two rows
if vv_points(1,size(vv_points,2)) ~= 0
    vv_points(:,1) = [];
    vv_points(:,1) = [];
end