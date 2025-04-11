function locations = computeVehicleLocations(bboxes, sensor)
% COMPUTEVEHICLELOCATIONS Computes the locations of vehicles in the world coordinate system.
%
%   LOCATIONS = COMPUTEVEHICLELOCATIONS(BBOXES, SENSOR) computes the locations of
%   vehicles based on the provided bounding boxes and sensor parameters.
%
%   Parameters:
%   - BBOXES: An M-by-4 matrix representing the bounding boxes of detected vehicles.
%             Each row contains [x, y, width, height] in image coordinates.
%   - SENSOR: Sensor parameters used to convert image coordinates to world coordinates.
%
%   Returns:
%   - LOCATIONS: An M-by-2 matrix representing the locations of vehicles in the world
%                coordinate system. Each row contains [x, y] coordinates.
%
%   See also: IMAGETOVEHICLE

locations = zeros(size(bboxes,1),2);
for i = 1:size(bboxes, 1)
    bbox  = bboxes(i, :);

    % Get [x,y] location of the center of the lower portion of the
    % detection bounding box in meters. bbox is [x, y, width, height] in
    % image coordinates, where [x,y] represents upper-left corner.
    yBottom = bbox(2) + bbox(4) - 1;
    xCenter = bbox(1) + (bbox(3)-1)/2; % approximate center

    locations(i,:) = imageToVehicle(sensor, [xCenter, yBottom]);
end
end