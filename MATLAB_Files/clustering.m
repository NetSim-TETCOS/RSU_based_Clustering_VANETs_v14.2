function [clusters, cluster_heads] = clustering(num_vehicles, num_rsus, rsu_ids, vehicles, rsus)
    % Create Voronoi diagram
    rsus_perturbed = rsus + randn(size(rsus)) * 0.01; % Add small random perturbation
    % Check if there are at least three unique points
unique_points = unique(rsus_perturbed, 'rows');
if size(unique_points, 1) >= 3
    % Call Voronoi only if we have enough unique points
    [vx, vy] = voronoi(rsus_perturbed(:, 1), rsus_perturbed(:, 2));
else
    warning('At least three unique points are required for Voronoi diagram.');
    vx = []; % or some default value
    vy = [];
end

     % Calculate the range and padding for the axes
    x_range = max([vehicles(:, 1); rsus(:, 1)]) + 100; % Adding padding for origin
    y_range = max([vehicles(:, 2); rsus(:, 2)]) + 100; % Adding padding for origin
    x_padding = 0.1 * x_range; % 10% padding
    y_padding = 0.1 * y_range; % 10% padding

    % Calculate distances between vehicles and RSUs
    distances = pdist2(vehicles, rsus);

    % Initialize clusters column vector
    clusters = zeros(num_vehicles, 1);

    % Store the RSU IDs as cluster heads
    cluster_heads = rsu_ids;

    % Form clusters based on the closest RSU for each vehicle
    for i = 1:num_vehicles
        [~, closest_rsu] = min(distances(i, :)); % Find the index of closest RSU
        clusters(i) = closest_rsu; % Assign the RSU index as the cluster ID
    end

    % Create axes handle
    axes_handle = gca;

    % Plot Voronoi diagram
    plot(vx, vy, 'k--');
    hold(axes_handle, 'on');
    
    % Plot RSUs
    scatter(axes_handle, rsus(:, 1), rsus(:, 2), 200, 'r', 'filled');

    % Plot clusters
    for i = 1:num_rsus
        cluster_indices = find(clusters == i);
        cluster_coordinates = vehicles(cluster_indices, :);
        scatter(axes_handle, cluster_coordinates(:, 1), cluster_coordinates(:, 2), 100, 'g', 'filled');
    end
    
    % Add labels for RSUs
    for i = 1:num_rsus
        text(axes_handle, rsus(i, 1), rsus(i, 2), ['RSU ' num2str(rsu_ids(i))], 'Color', 'black', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    end
    
    xlabel(axes_handle, 'X in m');
    ylabel(axes_handle, 'Y in m');
    title(axes_handle, 'Vehicle Clustering around RSUs');
    axis(axes_handle, [0, x_range + x_padding, 0, y_range + y_padding]);
    grid(axes_handle, 'on');
    hold(axes_handle, 'off');
end
