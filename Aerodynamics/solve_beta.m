function beta = solve_beta(theta, Ma1, k, branch)
%SOLVE_BETA Solve theta-beta-M relation for beta using fzero
%
% Inputs:
%   theta  - flow deflection angle [rad]
%   Ma1    - upstream Mach number
%   k      - gamma
%   branch - "weak" or "strong" (default "weak")
%
% Output:
%   beta   - shock angle [rad]

    if nargin < 4 || isempty(branch)
        branch = "weak";
    end

    if Ma1 < 1
        error('Ma1 must be greater than 1.');
    end

    eps_val = 1e-8;
    tol     = 1e-8;

    beta_min_phys = asin(1 / Ma1);

    f = @(b) tan(theta) - ...
        (2 .* cot(b) .* (Ma1.^2 .* sin(b).^2 - 1)) ./ ...
        (Ma1.^2 .* (k + cos(2 .* b)) + 2);

    switch lower(string(branch))
        case "weak"
            a = beta_min_phys;
            b = pi/2;

            % Check boundary root first
            if abs(f(a)) < tol
                beta = a;
                return
            end

            beta = find_root_in_interval(f, a + eps_val, b - eps_val, tol);

        case "strong"
            a = pi/2;
            b = pi - eps_val;

            % Check boundary root first
            if abs(f(a)) < tol
                beta = a;
                return
            end

            beta = find_root_in_interval(f, a + eps_val, b, tol);

        otherwise
            error('branch must be "weak" or "strong".')
    end
end


function root = find_root_in_interval(f, a, b, tol)

    root = NaN;

    N = 2000;
    x = linspace(a, b, N);
    y = NaN(size(x));

    for i = 1:N
        yi = f(x(i));
        if isfinite(yi) && isreal(yi)
            y(i) = yi;
        end
    end

    % Exact or near-exact sampled root
    [min_abs_y, idx] = min(abs(y));
    if ~isempty(idx) && isfinite(min_abs_y) && min_abs_y < tol
        root = x(idx);
        return
    end

    % Standard sign-change search
    for i = 1:N-1
        if isnan(y(i)) || isnan(y(i+1))
            continue
        end

        if y(i) * y(i+1) < 0
            root = fzero(f, [x(i), x(i+1)]);
            return
        end
    end
end