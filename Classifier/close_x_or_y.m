function closeto = close_x_or_y(land1,land2,thresh)
%%% Landmarks must be of the same orientation
    closeto = 0;
    dy = land1(2) - land1(4);
    dx = land1(1) - land1(3);
    angle = abs(atan2(dy,dx));
    if (size(land1,1) >= 6) && (size(land2,1) >= 6)
        if (angle == 0) || (angle == pi)
            error = abs(land1(5) - land2(5));
        else
            error = abs(land1(6) - land2(6));
        end
    else
        center1 = [mean([land1(1),land1(3)]),mean([land1(2),land1(4)])];
        center2 = [mean([land2(1),land2(3)]),mean([land2(2),land2(4)])];
        if (angle == 0) || (angle == pi)
            error = abs(center1(1) - center2(1));
        else
            error = abs(center1(2) - center2(2));
        end
    end
    if error < thresh
        closeto = 1;
    end