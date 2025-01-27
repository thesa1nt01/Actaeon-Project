function landmarks = merge_landmarks2(prev_land)
%%% landmark structure = [endpoint x1, endpoint y1,
%%%                       endpoint x2, endpoint y2,
%%%                       center x, center y,
%%%                       variance, count]
%%% When marking records for deletion, set count to zero
landmarks = [];
count_thresh = 5;
x_y_thresh = 10;
%prev_land
if ~isempty(prev_land)
    for pl_ndx1 = 1:size(prev_land,1)
        error = 1e6;
        sm_land_ndx = 0;
        large_land_ndx = 0;
        same_or = 0;
        %%% Find the closest neighbor %%%
        if (prev_land(pl_ndx1,8)~=0) %%% If the record isn't marked for deletion
            draw_circle(prev_land(pl_ndx1,5),prev_land(pl_ndx1,6),prev_land(pl_ndx1,7),'r')
            %input('Pause: merge land 13')
            for pl_ndx2 = 1:size(prev_land,1)
                if (prev_land(pl_ndx2,8)~=0) && (pl_ndx1 ~= pl_ndx2)%%% If the record isn't marked for deletion
                    draw_circle(prev_land(pl_ndx1,5),prev_land(pl_ndx1,6),prev_land(pl_ndx1,7),'g')                    
                    same_or = same_orient(prev_land(pl_ndx1,:),prev_land(pl_ndx2,:));
                    error = sqrt((prev_land(pl_ndx1,5) - prev_land(pl_ndx2,5))^2 + (prev_land(pl_ndx1,6) - prev_land(pl_ndx2,6))^2);
                    
                    %%% Find the longer landmark %%%
                    pl1_len = sqrt((prev_land(pl_ndx1,1) + prev_land(pl_ndx1,3))^2 + (prev_land(pl_ndx1,2) + prev_land(pl_ndx1,4))^2);
                    pl2_len = sqrt((prev_land(pl_ndx2,1) + prev_land(pl_ndx2,3))^2 + (prev_land(pl_ndx2,2) + prev_land(pl_ndx2,4))^2);
                    if pl1_len > pl2_len
                        large_land_ndx = pl_ndx1;
                        sm_land_ndx = pl_ndx2;
                    else
                        large_land_ndx = pl_ndx2;
                        sm_land_ndx = pl_ndx1;
                    end
                end
                
                %%% If your neighbor is within your variance circle or vice versa,
                %%% merge %%%
                if (large_land_ndx~=0) && (error < prev_land(large_land_ndx,7))
                    cutoff = 5;
                    order = 6;
                    count_l = prev_land(large_land_ndx,8);
                    count_s = prev_land(sm_land_ndx,8);
                    count_t = prev_land(large_land_ndx,8) + prev_land(sm_land_ndx,8);
                    w_l = exp(count_l);
                    w_s = exp(count_s);
                    sum_w = w_l + w_s;
%                     %%% Update Mean %%% % Mean is updated via the variance, the
%                     % lower the variance, the larger the weight %
                     sum_var = prev_land(large_land_ndx,7) + prev_land(sm_land_ndx,7);
%                     prev_land(large_land_ndx,5) = (w_l/sum_w)*prev_land(large_land_ndx,5) + (w_s/sum_w)*prev_land(sm_land_ndx,5);
%                     prev_land(large_land_ndx,6) = (w_l/sum_w)*prev_land(large_land_ndx,6) + (w_s/sum_w)*prev_land(sm_land_ndx,6);
                    %%% Update Variance %%%
                    variance = (prev_land(sm_land_ndx,7)/sum_var)*prev_land(large_land_ndx,7) + (prev_land(large_land_ndx,7)/sum_var)*prev_land(sm_land_ndx,7);
                    %%% Update Mean %%% 
                    %%% Orientation must be 0,pi,-pi,pi/2, or -pi/2
                    dy = prev_land(large_land_ndx,2) - prev_land(large_land_ndx,4);
                    dx = prev_land(large_land_ndx,1) - prev_land(large_land_ndx,3);
                    angle = abs(atan2(dy,dx));
                    center = [0,0];
                    center(1) = prev_land(large_land_ndx,5);
                    center(2) = prev_land(large_land_ndx,6);
                    % Update Endpoints %
                        if (angle == 0) || (angle == pi) %%% Merge x
                            max_x = 0;
                            min_x = 1e6;
                            if prev_land(large_land_ndx,1) > max_x
                                max_x = prev_land(large_land_ndx,1);
                            end
                            if prev_land(large_land_ndx,1) < min_x
                                min_x = prev_land(large_land_ndx,1);
                            end
                            if prev_land(large_land_ndx,3) > max_x
                                max_x = prev_land(large_land_ndx,3);
                            end
                            if prev_land(large_land_ndx,3) < min_x
                                min_x = prev_land(large_land_ndx,3);
                            end
                            if prev_land(sm_land_ndx,1) > max_x
                                max_x = prev_land(sm_land_ndx,1);
                            end
                            if prev_land(sm_land_ndx,1) < min_x
                                min_x = prev_land(sm_land_ndx,1);
                            end
                            if prev_land(sm_land_ndx,3) > max_x
                                max_x = prev_land(sm_land_ndx,3);
                            end
                            if prev_land(sm_land_ndx,3) < min_x
                                min_x = prev_land(sm_land_ndx,3);
                            end
                            
                            endpoint1 = [min_x,center(2)];
                            endpoint2 = [max_x,center(2)];
                        else %%% Merge y
                            max_y = 0;
                            min_y = 1e6;
                            if prev_land(large_land_ndx,2) > max_y
                                max_y = prev_land(large_land_ndx,2);
                            end
                            if prev_land(large_land_ndx,2) < min_y
                                min_y = prev_land(large_land_ndx,2);
                            end
                            if prev_land(large_land_ndx,4) > max_y
                                max_y = prev_land(large_land_ndx,4);
                            end
                            if prev_land(large_land_ndx,4) < min_y
                                min_y = prev_land(large_land_ndx,4);
                            end
                            if prev_land(sm_land_ndx,2) > max_y
                                max_y = prev_land(sm_land_ndx,2);
                            end
                            if prev_land(sm_land_ndx,2) < min_y
                                min_y = prev_land(sm_land_ndx,2);
                            end
                            if prev_land(sm_land_ndx,4) > max_y
                                max_y = prev_land(sm_land_ndx,4);
                            end
                            if prev_land(sm_land_ndx,4) < min_y
                                min_y = prev_land(sm_land_ndx,4);
                            end
                            
                            endpoint1 = [center(1),min_y];
                            endpoint2 = [center(1),max_y];
                        end
                        prev_land(large_land_ndx,:) = [endpoint1,endpoint2,center,variance,count_t];
                        %%% Mark sm_land_ndx for deletion
                        prev_land(sm_land_ndx,8) = 0;
                      
                    
                %%% If the landmark's endpoints are sufficiently close to it's neighbor, merge %          
                %%% Check for same orientation first %%%
                elseif (large_land_ndx~=0) && same_or && (prev_land(large_land_ndx,8) > count_thresh)
                    if prev_land(sm_land_ndx,8) > prev_land(large_land_ndx,8)
                        temp = large_land_ndx;
                        large_land_ndx = sm_land_ndx;
                        sm_land_ndx = temp;                       
                    end
                    d_thresh = 5; %cm
                    r1 = sqrt((prev_land(large_land_ndx,1) - prev_land(sm_land_ndx,1))^2 + ((prev_land(large_land_ndx,2) - prev_land(sm_land_ndx,2))^2));
                    r2 = sqrt((prev_land(large_land_ndx,1) - prev_land(sm_land_ndx,3))^2 + ((prev_land(large_land_ndx,2) - prev_land(sm_land_ndx,4))^2));
                    r3 = sqrt((prev_land(large_land_ndx,3) - prev_land(sm_land_ndx,1))^2 + ((prev_land(large_land_ndx,4) - prev_land(sm_land_ndx,2))^2));
                    r4 = sqrt((prev_land(large_land_ndx,3) - prev_land(sm_land_ndx,3))^2 + ((prev_land(large_land_ndx,4) - prev_land(sm_land_ndx,4))^2));
                    if (r1 < d_thresh) || (r2 < d_thresh) || (r3 < d_thresh) || (r4 < d_thresh)
                        %%% Orientation must be 0,pi,-pi,pi/2, or -pi/2
                        dy = prev_land(large_land_ndx,2) - prev_land(large_land_ndx,4);
                        dx = prev_land(large_land_ndx,1) - prev_land(large_land_ndx,3);
                        angle = abs(atan2(dy,dx));
                        center = [0,0];
                        %%% Update Mean %%% % Mean is updated via the variance, the
                        % lower the variance, the larger the weight %
%                         sum_var = prev_land(large_land_ndx,7) + prev_land(sm_land_ndx,7);
%                         center(1) = (prev_land(sm_land_ndx,7)/sum_var)*prev_land(large_land_ndx,5) + (prev_land(large_land_ndx,7)/sum_var)*prev_land(sm_land_ndx,5);
%                         center(2) = (prev_land(sm_land_ndx,7)/sum_var)*prev_land(large_land_ndx,6) + (prev_land(large_land_ndx,7)/sum_var)*prev_land(sm_land_ndx,6);
                          center(1) = prev_land(large_land_ndx,5);
                          center(2) = prev_land(large_land_ndx,6);
                        
                        if (angle == 0) || (angle == pi) %%% Merge x
                            max_x = 0;
                            min_x = 1e6;
                            if prev_land(large_land_ndx,1) > max_x
                                max_x = prev_land(large_land_ndx,1);
                            end
                            if prev_land(large_land_ndx,1) < min_x
                                min_x = prev_land(large_land_ndx,1);
                            end
                            if prev_land(large_land_ndx,3) > max_x
                                max_x = prev_land(large_land_ndx,3);
                            end
                            if prev_land(large_land_ndx,3) < min_x
                                min_x = prev_land(large_land_ndx,3);
                            end
                            if prev_land(sm_land_ndx,1) > max_x
                                max_x = prev_land(sm_land_ndx,1);
                            end
                            if prev_land(sm_land_ndx,1) < min_x
                                min_x = prev_land(sm_land_ndx,1);
                            end
                            if prev_land(sm_land_ndx,3) > max_x
                                max_x = prev_land(sm_land_ndx,3);
                            end
                            if prev_land(sm_land_ndx,3) < min_x
                                min_x = prev_land(sm_land_ndx,3);
                            end
                            
                            endpoint1 = [min_x,center(2)];
                            endpoint2 = [max_x,center(2)];
                        else %%% Merge y
                            max_y = 0;
                            min_y = 1e6;
                            if prev_land(large_land_ndx,2) > max_y
                                max_y = prev_land(large_land_ndx,2);
                            end
                            if prev_land(large_land_ndx,2) < min_y
                                min_y = prev_land(large_land_ndx,2);
                            end
                            if prev_land(large_land_ndx,4) > max_y
                                max_y = prev_land(large_land_ndx,4);
                            end
                            if prev_land(large_land_ndx,4) < min_y
                                min_y = prev_land(large_land_ndx,4);
                            end
                            if prev_land(sm_land_ndx,2) > max_y
                                max_y = prev_land(sm_land_ndx,2);
                            end
                            if prev_land(sm_land_ndx,2) < min_y
                                min_y = prev_land(sm_land_ndx,2);
                            end
                            if prev_land(sm_land_ndx,4) > max_y
                                max_y = prev_land(sm_land_ndx,4);
                            end
                            if prev_land(sm_land_ndx,4) < min_y
                                min_y = prev_land(sm_land_ndx,4);
                            end
                            
                            endpoint1 = [center(1),min_y];
                            endpoint2 = [center(1),max_y];
                        end
                        variance = mean([prev_land(large_land_ndx,7) , prev_land(sm_land_ndx,7)]);
                        count = prev_land(large_land_ndx,8) + prev_land(sm_land_ndx,8);
                        prev_land(large_land_ndx,:) = [endpoint1,endpoint2,center,variance,count];
                        %%% Mark sm_land_ndx for deletion
                        prev_land(sm_land_ndx,8) = 0;
                    elseif  overlap(prev_land(large_land_ndx,:),prev_land(sm_land_ndx,:)) && close_x_or_y(prev_land(large_land_ndx,:),prev_land(sm_land_ndx,:),x_y_thresh)%%% End points overlap and sufficiently close
                        %%% Merge %%%
                        %%% Orientation must be 0,pi,-pi,pi/2, or -pi/2
                        dy = prev_land(large_land_ndx,2) - prev_land(large_land_ndx,4);
                        dx = prev_land(large_land_ndx,1) - prev_land(large_land_ndx,3);
                        angle = abs(atan2(dy,dx));
                        center = [0,0];
                        %%% Update Mean %%% % Mean is updated via the variance, the
                        % lower the variance, the larger the weight %
%                         sum_var = prev_land(large_land_ndx,7) + prev_land(sm_land_ndx,7);
%                         center(1) = (prev_land(sm_land_ndx,7)/sum_var)*prev_land(large_land_ndx,5) + (prev_land(large_land_ndx,7)/sum_var)*prev_land(sm_land_ndx,5);
%                         center(2) = (prev_land(sm_land_ndx,7)/sum_var)*prev_land(large_land_ndx,6) + (prev_land(large_land_ndx,7)/sum_var)*prev_land(sm_land_ndx,6);
                          center(1) = prev_land(large_land_ndx,5);
                          center(2) = prev_land(large_land_ndx,6);
                        
                        if (angle == 0) || (angle == pi) %%% Merge x
                            max_x = 0;
                            min_x = 1e6;
                            if prev_land(large_land_ndx,1) > max_x
                                max_x = prev_land(large_land_ndx,1);
                            end
                            if prev_land(large_land_ndx,1) < min_x
                                min_x = prev_land(large_land_ndx,1);
                            end
                            if prev_land(large_land_ndx,3) > max_x
                                max_x = prev_land(large_land_ndx,3);
                            end
                            if prev_land(large_land_ndx,3) < min_x
                                min_x = prev_land(large_land_ndx,3);
                            end
                            if prev_land(sm_land_ndx,1) > max_x
                                max_x = prev_land(sm_land_ndx,1);
                            end
                            if prev_land(sm_land_ndx,1) < min_x
                                min_x = prev_land(sm_land_ndx,1);
                            end
                            if prev_land(sm_land_ndx,3) > max_x
                                max_x = prev_land(sm_land_ndx,3);
                            end
                            if prev_land(sm_land_ndx,3) < min_x
                                min_x = prev_land(sm_land_ndx,3);
                            end
                            
                            endpoint1 = [min_x,center(2)];
                            endpoint2 = [max_x,center(2)];
                        else %%% Merge y
                            max_y = 0;
                            min_y = 1e6;
                            if prev_land(large_land_ndx,2) > max_y
                                max_y = prev_land(large_land_ndx,2);
                            end
                            if prev_land(large_land_ndx,2) < min_y
                                min_y = prev_land(large_land_ndx,2);
                            end
                            if prev_land(large_land_ndx,4) > max_y
                                max_y = prev_land(large_land_ndx,4);
                            end
                            if prev_land(large_land_ndx,4) < min_y
                                min_y = prev_land(large_land_ndx,4);
                            end
                            if prev_land(sm_land_ndx,2) > max_y
                                max_y = prev_land(sm_land_ndx,2);
                            end
                            if prev_land(sm_land_ndx,2) < min_y
                                min_y = prev_land(sm_land_ndx,2);
                            end
                            if prev_land(sm_land_ndx,4) > max_y
                                max_y = prev_land(sm_land_ndx,4);
                            end
                            if prev_land(sm_land_ndx,4) < min_y
                                min_y = prev_land(sm_land_ndx,4);
                            end
                            
                            endpoint1 = [center(1),min_y];
                            endpoint2 = [center(1),max_y];
                        end
                        variance = mean([prev_land(large_land_ndx,7) , prev_land(sm_land_ndx,7)]);
                        count = prev_land(large_land_ndx,8) + prev_land(sm_land_ndx,8);
                        prev_land(large_land_ndx,:) = [endpoint1,endpoint2,center,variance,count];
                        %%% Mark sm_land_ndx for deletion
                        prev_land(sm_land_ndx,8) = 0;
                    end
                end
            end
        end
    end
    
    %%% Delete obsolete records %%%
    for pl_ndx = size(prev_land,1):-1:1
        %pl_ndx
        %prev_land
        if prev_land(pl_ndx,8) == 0
            prev_land(pl_ndx,:) = [];
        end
        
    end
    landmarks = prev_land;
    %%% Draw Variances %%%
    for l_ndx = 1:size(landmarks,1)
        draw_circle(landmarks(l_ndx,5),landmarks(l_ndx,6),landmarks(l_ndx,7),'k')
    end
end