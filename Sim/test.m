clear; clc; close all

dimensions = [10, 3];

mass = 10;
spacing = 1;
k = 100;
c_damp = 1;
length_resting = 1;

[pos, mass_all] = generate_masses(dimensions, spacing, mass);
springs = generate_springs(dimensions, k, length_resting);

num_nodes = size(pos, 1);
vel = zeros(num_nodes, 2);
P   = zeros(num_nodes, 2);

for m_i = 1:dimensions(1)
    for m_j = 1:dimensions(2)
        idx = sub2ind(dimensions, m_i, m_j);

        if m_j == 1 && m_i > dimensions(1)/2
            P(idx, :) = [0.1, 0];
        end
    end
end

dt = 1e-2;
num_sec = 10;
tspan = 0:dt:num_sec;
num_steps = length(tspan);

pos_all = zeros(num_nodes, 2, num_steps);

idx1 = springs(:,1);
idx2 = springs(:,2);
k_all = springs(:,3);
L0    = springs(:,4);

for i = 1:num_steps
    pos_all(:,:,i) = pos;

    pos1 = pos(idx1, :);
    pos2 = pos(idx2, :);

    vel1 = vel(idx1, :);
    vel2 = vel(idx2, :);

    vec = pos2 - pos1;
    L = sqrt(sum(vec.^2, 2));

    u = vec ./ L;
    u(L == 0, :) = 0;

    dist   = L - L0;
    v_rel  = vel2 - vel1;
    v_proj = sum(v_rel .* u, 2);

    F_mag = k_all .* dist + c_damp .* v_proj;
    F = u .* F_mag;

    Fx = accumarray(idx1,  F(:,1), [num_nodes, 1]) + accumarray(idx2, -F(:,1), [num_nodes, 1]);
    Fy = accumarray(idx1,  F(:,2), [num_nodes, 1]) + accumarray(idx2, -F(:,2), [num_nodes, 1]);

    accel = [Fx ./ mass_all, Fy ./ mass_all] + P;

    vel = vel + accel * dt;
    pos = pos + vel * dt;
end

%% PLOT

x_min_all = squeeze(min(pos_all(:,1,:), [], 1));
x_max_all = squeeze(max(pos_all(:,1,:), [], 1));
y_min_all = squeeze(min(pos_all(:,2,:), [], 1));
y_max_all = squeeze(max(pos_all(:,2,:), [], 1));

width_all  = x_max_all - x_min_all;
height_all = y_max_all - y_min_all;

pad = 0.5;
max_width  = max(width_all) + 2*pad;
max_height = max(height_all) + 2*pad;

figure(1)

for i = 1:100:num_steps
    clf
    hold on

    pos_curr = pos_all(:,:,i);

    draw_masses(pos_curr);
    draw_springs(springs, pos_curr)
    title(sprintf("t = %0.2f", tspan(i)));

    x_center = 0.5 * (x_min_all(i) + x_max_all(i));
    y_center = 0.5 * (y_min_all(i) + y_max_all(i));

    xlim(x_center + [-max_width/2,  max_width/2]);
    ylim(y_center + [-max_height/2, max_height/2]);
    axis equal

    pause(0.01)
end

function draw_masses(pos)
plot(pos(:,1), pos(:,2), '.k', 'MarkerSize', 10);
end

function draw_springs(springs, pos)
x = [pos(springs(:,1),1), pos(springs(:,2),1)]';
y = [pos(springs(:,1),2), pos(springs(:,2),2)]';
plot(x, y, '-k')
end

function [pos, mass_all] = generate_masses(dimensions, spacing, mass)
num_nodes = prod(dimensions);
pos = zeros(num_nodes, 2);

for i = 1:dimensions(1)
    for j = 1:dimensions(2)
        idx = sub2ind(dimensions, i, j);
        pos(idx, :) = [j*spacing, i*spacing];
    end
end

mass_all = mass * ones(num_nodes, 1);
end

function springs = generate_springs(dimensions, k, rest_length)
num_h = dimensions(1) * (dimensions(2)-1);
num_v = (dimensions(1)-1) * dimensions(2);
num_d = 2 * (dimensions(1)-1) * (dimensions(2)-1);

num_springs = num_h + num_v + num_d;
springs = zeros(num_springs, 4);

spring_idx = 1;

for i = 1:dimensions(1)
    for j = 1:dimensions(2)-1
        springs(spring_idx,:) = [ ...
            sub2ind(dimensions, i, j), ...
            sub2ind(dimensions, i, j+1), ...
            k, ...
            rest_length];
        spring_idx = spring_idx + 1;
    end
end

for i = 1:dimensions(1)-1
    for j = 1:dimensions(2)
        springs(spring_idx,:) = [ ...
            sub2ind(dimensions, i, j), ...
            sub2ind(dimensions, i+1, j), ...
            k, ...
            rest_length];
        spring_idx = spring_idx + 1;
    end
end

for i = 1:dimensions(1)-1
    for j = 1:dimensions(2)-1
        springs(spring_idx,:) = [ ...
            sub2ind(dimensions, i, j), ...
            sub2ind(dimensions, i+1, j+1), ...
            k, ...
            sqrt(2*rest_length)];
        spring_idx = spring_idx + 1;

        springs(spring_idx,:) = [ ...
            sub2ind(dimensions, i+1, j), ...
            sub2ind(dimensions, i, j+1), ...
            k, ...
            sqrt(2*rest_length)];
        spring_idx = spring_idx + 1;
    end
end
end