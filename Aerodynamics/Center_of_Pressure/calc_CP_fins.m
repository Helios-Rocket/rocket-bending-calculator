function CP = calc_CP_fins(fins, M)
    if isfield(fins,'xPt') % Free-form fins (ONLY GUARANTEED TO WORK IF FULLY CONVEX)
        finGon = polyshape(fins.xPt,fins.yPt);
        A_fin = area(finGon);
        s = max(fins.yPt);
        R = 2 * s^2 / A_fin;
        [~,y_mac] = centroid(finGon); % get span position of mean chord from centroid of fin
        % Find points where mean chord intersects boundary (beginning and end of MAC)
        y1 = fins.yPt(1:end-1);
        y2 = fins.yPt(2:end);
        mask = (y_mac >= min(y1,y2)) & (y_mac <= max(y1,y2)) & (y1 ~= y2);  % find line segment containing y_mac
        t = (y_mac - y1(mask)) ./ (y2(mask) - y1(mask));
        x_ints = fins.xPt(mask) + t .* (fins.xPt(find(mask)+1) - fins.xPt(mask));

        x_le_mac = x_ints(1);
        cbar = x_ints(2)-x_ints(1);
        
    else
        cr = fins.cr;
        ct = fins.ct;
        xr = fins.xr;
        s  = fins.s;
    
        A_fin = 0.5 * (cr + ct) * s;
        R = 2 * s^2 / A_fin;
    
        cbar = (2/3) * (cr + ct - (cr*ct)/(cr + ct));
    
        x_le_mac = (xr/3) * (cr + 2*ct) / (cr + ct);
    end

    xf_c = calc_cp_mac_fraction(M, R);

    CP = x_le_mac + xf_c * cbar;
end

function xf_c = calc_cp_mac_fraction(M, R)
    xf_c = zeros(size(M));

    f2  = f_sup(2, R);
    fp2 = f_sup_prime(2, R);

    A = [
        0.5^5   0.5^4   0.5^3   0.5^2   0.5   1
        5*0.5^4 4*0.5^3 3*0.5^2 2*0.5   1     0
        2^5     2^4     2^3     2^2     2     1
        5*2^4   4*2^3   3*2^2   2*2     1     0
        20*2^3  12*2^2  6*2     2       0     0
        60*2^2  24*2    6       0       0     0
    ];

    b = [
        0.25
        0
        f2
        fp2
        0
        0
    ];

    a = A \ b;

    for i = 1:numel(M)
        Mi = M(i);

        if Mi <= 0.5
            xf_c(i) = 0.25;
        elseif Mi >= 2
            xf_c(i) = f_sup(Mi, R);
        else
            xf_c(i) = polyval(a, Mi);
        end
    end
end

function y = f_sup(M, R)
    beta = sqrt(M^2 - 1);
    y = (R*beta - 0.67) / (2*R*beta - 1);
end

function y = f_sup_prime(M, R)
    beta = sqrt(M^2 - 1);
    y = 0.34 * R * M / (beta * (2*R*beta - 1)^2);
end