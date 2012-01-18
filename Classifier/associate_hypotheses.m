function [landmarks] = associate_hypotheses(prev_land, current_hypos)
%%% landmark structure = [endpoint x1, endpoint y1,
%%%                       endpoint x2, endpoint y2,
%%%                       center x, center y,
%%%                       variance, count]
landmarks = [];
gate = 1000;
if isempty(prev_land)
    for ch_ndx = 1:size(current_hypos,1)
        dy = current_hypos(ch_ndx,2) - current_hypos(ch_ndx,4);
        dx = current_hypos(ch_ndx,1) - current_hypos(ch_ndx,3);
        angle = atan2(dy,dx);
        r_len = sqrt(dy^2 + dx^2)/2;
        center = [mean([current_hypos(ch_ndx,1),current_hypos(ch_ndx,3)]),mean([current_hypos(ch_ndx,2),current_hypos(ch_ndx,4)])];
        an_0 = abs(angle);
        an_90 = abs(angle - pi/2);
        an_n90 = abs(angle + pi/2);
        an_180 = abs(angle - pi);
        if an_180 < an_0
            an_0 = an_180;
        end
        if an_n90 < an_90
            an_90 = an_n90;
        end
        if an_0 < an_90 %%% 0 degree orientation
            end_pt1 = [center(1) - r_len, center(2)];
            end_pt2 = [center(1) + r_len, center(2)];
        else %%% 90 degree orientation
            end_pt1 = [center(1), center(2) - r_len];
            end_pt2 = [center(1), center(2) + r_len];
        end
        new_land = [end_pt1,end_pt2,center,0.01,1];
        landmarks = [landmarks;new_land];
    end
else
    for ch_ndx = 1:size(current_hypos,1)
        min_pl_ndx = 0;
        min_dist = 1e6;
        for pl_ndx = 1:size(prev_land,1)
            center = [mean([current_hypos(ch_ndx,1),current_hypos(ch_ndx,3)]),mean([current_hypos(ch_ndx,2),current_hypos(ch_ndx,4)])];
            error = sqrt((prev_land(pl_ndx,5) - center(1))^2 + (prev_land(pl_ndx,6) - center(2))^2);
            if error < min_dist
                min_dist = error;
                min_pl_ndx = pl_ndx;
            end
        end
        (min_dist)*(prev_land(min_pl_ndx,7))
        if gate > (min_dist^2)*(prev_land(min_pl_ndx,7))
            center_h = [mean([current_hypos(ch_ndx,1),current_hypos(ch_ndx,3)]),mean([current_hypos(ch_ndx,2),current_hypos(ch_ndx,4)])];
            count = prev_land(min_pl_ndx,8);
            % Update Variance %
            variance = (1/count)*(min_dist) + ((count - 1)/count)*prev_land(min_pl_ndx,7);
            prev_land(min_pl_ndx,7) = variance;
%             % Update Mean %
%             center = [0,0];
%             center(1) = ((count - 1)/count)*prev_land(min_pl_ndx,5) + (1/count)*center_h(1);
%             center(2) = ((count - 1)/count)*prev_land(min_pl_ndx,6) + (1/count)*center_h(2);
            % Update Count %
            %count = prev_land(min_pl_ndx,8) + 1;
            prev_land(min_pl_ndx,8) = prev_land(min_pl_ndx,8) + 1;
%             % Update Endpoints %
%             dy = prev_land(min_pl_ndx,2) - prev_land(min_pl_ndx,4);
%             dx = prev_land(min_pl_ndx,1) - prev_land(min_pl_ndx,3);
%             angle = atan2(dy,dx);
%             r_len = sqrt(dy^2 + dx^2)/2;
%             
%             an_0 = abs(angle);
%             an_90 = abs(angle - pi/2);
%             an_n90 = abs(angle + pi/2);
%             an_180 = abs(angle - pi);
%             if an_180 < an_0
%                 an_0 = an_180;
%             end
%             if an_n90 < an_90
%                 an_90 = an_n90;
%             end
%             if an_0 < an_90 %%% 0 degree orientation
%                 end_pt1 = [prev_land(min_pl_ndx,5) - r_len, prev_land(min_pl_ndx,6)];
%                 end_pt2 = [prev_land(min_pl_ndx,5) + r_len, prev_land(min_pl_ndx,6)];
%             else %%% 90 degree orientation
%                 end_pt1 = [prev_land(min_pl_ndx,5), prev_land(min_pl_ndx,6) - r_len];
%                 end_pt2 = [prev_land(min_pl_ndx,5), prev_land(min_pl_ndx,6) + r_len];
%             end
%             %landmarks = [landmarks;end_pt1,end_pt2,center,variance,count];
%             prev_land(min_pl_ndx,:) = [end_pt1,end_pt2,center,variance,count];
            
        else
            dy = current_hypos(ch_ndx,2) - current_hypos(ch_ndx,4);
            dx = current_hypos(ch_ndx,1) - current_hypos(ch_ndx,3);
            angle = atan2(dy,dx)
            r_len = sqrt(dy^2 + dx^2)/2;
            center = [mean([current_hypos(ch_ndx,1),current_hypos(ch_ndx,3)]),mean([current_hypos(ch_ndx,2),current_hypos(ch_ndx,4)])];
            
            an_0 = abs(angle);
            an_90 = abs(angle - pi/2);
            an_n90 = abs(angle + pi/2);
            an_180 = abs(angle - pi);
            if an_180 < an_0
                an_0 = an_180;
            end
            if an_n90 < an_90
                an_90 = an_n90;
            end
            if an_0 < an_90 %%% 0 degree orientation
                end_pt1 = [center(1) - r_len, center(2)];
                end_pt2 = [center(1) + r_len, center(2)];
            else %%% 90 degree orientation
                end_pt1 = [center(1), center(2) - r_len];
                end_pt2 = [center(1), center(2) + r_len];
            end
            new_land = [end_pt1,end_pt2,center,0.01,1];
            landmarks = [landmarks;new_land];
        end
    end
    landmarks = [prev_land;landmarks];
end