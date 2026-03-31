clear; clc; close all

dimensions = [10, 3];

mass = 10;
spacing = 1;
k = 100;
c_damp = 1;
length_resting = 1;

springs = generate_springs(dimensions, k, length_resting);
masses  = generate_masses(dimensions, spacing, mass);
vels    = cell(dimensions);
P = cell(dimensions);

for m_i=1:dimensions(1)

    for m_j=1:dimensions(2)
        vels{m_i, m_j} = [0, 0];
        if m_j == 1 && m_i > dimensions(1)/2
            P{m_i, m_j} = [0.1, 0];
        else
            P{m_i, m_j} = [0, 0];
        end
    end
end

dt = 1e-2;
num_sec = 10;
tspan = 0:dt:num_sec;
num_steps = length(tspan);

pos_all = {masses};

for i = 1:num_steps
    pos_all{i} = masses;

    f_spring = calc_spring_forces(springs, masses, vels, c_damp);
    accels   = calc_mass_accels(masses, springs, f_spring, P);

    for m_i = 1:dimensions(1)
        for m_j = 1:dimensions(2)
            vels{m_i, m_j}(1:2) = vels{m_i, m_j}(1:2) + accels{m_i, m_j}*dt;
            masses{m_i, m_j}(1:2) = masses{m_i, m_j}(1:2) + vels{m_i, m_j}*dt;
        end
    end
end

%% PLOT

% Find the maximum width and height the structure ever reaches
max_width = 0;
max_height = 0;

for i = 1:num_steps
    x_all = zeros(dimensions(1), dimensions(2));
    y_all = zeros(dimensions(1), dimensions(2));

    for m_i = 1:dimensions(1)
        for m_j = 1:dimensions(2)
            pos = pos_all{i}{m_i, m_j}(1:2);
            x_all(m_i, m_j) = pos(1);
            y_all(m_i, m_j) = pos(2);
        end
    end

    width_i  = max(x_all(:)) - min(x_all(:));
    height_i = max(y_all(:)) - min(y_all(:));

    max_width  = max(max_width, width_i);
    max_height = max(max_height, height_i);
end

pad = 0.5;
max_width  = max_width + 2*pad;
max_height = max_height + 2*pad;

figure(1)

for i = 1:10:num_steps
    clf
    hold on

    draw_masses(pos_all{i});
    draw_springs(springs, pos_all{i})
    title(sprintf("t = %0.2f", tspan(i)));

    x_all = zeros(dimensions(1), dimensions(2));
    y_all = zeros(dimensions(1), dimensions(2));

    for m_i = 1:dimensions(1)
        for m_j = 1:dimensions(2)
            pos = pos_all{i}{m_i, m_j}(1:2);
            x_all(m_i, m_j) = pos(1);
            y_all(m_i, m_j) = pos(2);
        end
    end

    x_center = (max(x_all(:)) + min(x_all(:))) / 2;
    y_center = (max(y_all(:)) + min(y_all(:))) / 2;

    xlim(x_center + [-max_width/2,  max_width/2]);
    ylim(y_center + [-max_height/2, max_height/2]);
    axis equal

    pause(0.01)
end

function accels = calc_mass_accels(masses, springs, f_spring, P)

dimensions = size(masses);
accels = cell(size(masses));

for i = 1:numel(accels)
    accels{i} = [0, 0];
end

for i = 1:numel(f_spring)
    m1 = springs{i}{1};
    m2 = springs{i}{2};

    i1 = m1(1); j1 = m1(2);
    i2 = m2(1); j2 = m2(2);

    F = f_spring{i};

    accels{i1,j1} = accels{i1,j1} + F  / masses{i1,j1}(3);
    accels{i2,j2} = accels{i2,j2} - F  / masses{i2,j2}(3);
end

for m_i=1:dimensions(1)
    for m_j=1:dimensions(2)
        accels{m_i, m_j} = accels{m_i, m_j} + P{m_i, m_j};
    end
end

end

function f_spring = calc_spring_forces(springs, masses, vels, c_damp)

f_spring = cell(size(springs));
    
for i = 1:numel(springs)
    idx1 = springs{i}{1};
    idx2 = springs{i}{2};

    pos1 = masses{idx1(1), idx1(2)}(1:2);
    pos2 = masses{idx2(1), idx2(2)}(1:2);

    v1 = vels{idx1(1), idx1(2)}(1:2);
    v2 = vels{idx2(1), idx2(2)}(1:2);

    vec = pos2 - pos1;
    L = norm(vec);

    if L == 0
        f_spring{i} = [0, 0];
        continue
    end

    u = vec / L;

    dist = L - springs{i}{4};
    v_rel = v2 - v1;
    v_proj = dot(v_rel, u);

    k = springs{i}{3};

    % Force on mass 1
    F_spring = k * dist * u;
    F_damp   = c_damp * v_proj * u;
    f_spring{i} = F_spring + F_damp;
end

end

function draw_masses(masses)
dimensions = size(masses);
for i = 1:dimensions(1)
    for j = 1:dimensions(2)
        plot(masses{i, j}(1), masses{i, j}(2), '.k', 'MarkerSize', 10);
    end
end
end

function draw_springs(springs, masses)

for i = 1:numel(springs)
    pos1 = masses{springs{i}{1}(1), springs{i}{1}(2)}(1:2);
    pos2 = masses{springs{i}{2}(1), springs{i}{2}(2)}(1:2);

    plot([pos1(1), pos2(1)], [pos1(2), pos2(2)], '-k')
end

end

function masses = generate_masses(dimensions, spacing, mass)
masses = cell(dimensions);
for i = 1:dimensions(1)
    for j = 1:dimensions(2)
        masses{i, j} = [j*spacing, i*spacing, mass];
    end
end

end

function springs = generate_springs(dimensions, k, rest_length)
springs = {};
spring_idx = 1;

for i = 1:dimensions(1)
    for j = 1:dimensions(2)-1

        springs{spring_idx} = {[i, j], [i, j+1], k, rest_length};
        spring_idx = spring_idx + 1;

    end
end

for i = 1:dimensions(1)-1
    for j = 1:dimensions(2)

        springs{spring_idx} = {[i, j], [i+1, j], k, rest_length};
        spring_idx = spring_idx + 1;

    end
end

for i = 1:dimensions(1)-1
    for j = 1:dimensions(2)-1
        springs{spring_idx} = {[i, j], [i+1, j+1], k, sqrt(2*rest_length)};
        spring_idx = spring_idx + 1;

        springs{spring_idx} = {[i+1, j], [i, j+1], k, sqrt(2*rest_length)};
        spring_idx = spring_idx + 1;
    end
end

end
