%% Script to find the amplitude and latency of the fusiform faces response
% Manually indicate the peak. The script will snap to the graph
% automatically and find the latency and amplitude of the actual minimum.
% If the peak is bicuspid, indicate a window around the two peaks,
% and the script will fit a parabola through it and take the minimum of
% the parabola as the peak of the face response. 
%  
% All plots will be saved in the current directoy
% The output variable is peak_data, with columns:
% Latency_left, Amplitude_left, Latency_right, Amplitude_right



close all
clear all
clc

p = opm_study_config_faces_voxelwise();

num_subjects = size(p.subject_data, 1);

idx_left = 1;
idx_right = 2;

toi = [0.1, 0.4]; % Time window of interest, vertical lines will be plotted

is_valley = true; % false if looking for peak (M100), true if valley (M170)

load('fusiform_l.mat')
load('fusiform_r.mat')
load('time.mat')

flip_l = p.subject_data.ffg_flip_l; 
flip_r = p.subject_data.ffg_flip_r; 

%% Voxelwise data

maxpower_data_l(flip_l == 1, :) = -maxpower_data_l(flip_l == 1, :);
maxpower_data_r(flip_r == 1, :) = -maxpower_data_r(flip_r == 1, :);

ts_flipped = zeros(2, length(time), num_subjects);

ts_flipped(idx_left, :, :) = maxpower_data_l';
ts_flipped(idx_right, :, :) = maxpower_data_r';

%% Coordinate data (if using coordinates instead of grid)

% Define rois
%rois = [55, 56];

% Load
%data = load_timeseries_data(p, rois, return_mean, extract_top_trials);
%time = data.time;

%ts_flipped = flip_timeseries(p, data.ts);

%% Find peaks

% Initialize
peak_data = zeros(num_subjects, 4);

for ss = 4%1:num_subjects
    disp(p.subject(ss))

    linecolor_l = 'b';
    linecolor_r = 'r';

    figure
    hold on
    plot(time, squeeze(ts_flipped(idx_left, :, ss)), 'LineWidth',2, 'Color',linecolor_l)
    plot(time, squeeze(ts_flipped(idx_right, :, ss)), 'LineWidth',2, 'Color',linecolor_r)
    xline(toi)
    ylim([-10 10])
    xlim([-0.1 0.5])
    yline([-3, 3])
    xlabel('Time (s)')
    ylabel('Amplitude (z-score)')
    title(char(p.subject_data.subject(ss)))
    legend({'Left'; 'Right'}, 'AutoUpdate','off')

    % LEFT
    disp('Select peak in left hemisphere or press enter to skip')
    [x1_clicks, ~] = ginput(2);
    if ~isempty(x1_clicks)
        x1_start = min(x1_clicks);
        x1_end = max(x1_clicks);
        search_window_idx = time >= x1_start & time <= x1_end;

        % Extract signal in window
        signal_l = squeeze(ts_flipped(idx_left, :, ss));
        signal_window = signal_l(search_window_idx);
        time_window = time(search_window_idx);

        % Plot to visualize
        plot(time_window, signal_window, 'k', 'LineWidth',3)

        % Find extrema in window
        is_max_window = islocalmax(signal_window);
        is_min_window = islocalmin(signal_window);

        if is_valley
            extrema = is_min_window;
        else
            extrema = is_max_window;
        end

        if sum(extrema) == 1
            % Exactly one minimum found
            idx_min = find(extrema);
            l1 = time_window(idx_min);
            a1 = signal_window(idx_min);
            disp('Local minimum found - do not fit parabola')
        elseif sum(extrema) == 2
            disp('Biphid found - fitting parabola')
            [l1, a1] = fitParabola(squeeze(ts_flipped(idx_left, :, ss)), time, time_window(extrema));
        elseif sum(extrema) == 3
            disp('Triphid found - fitting parabola')
            times_min = time_window(extrema);
            times_min = [times_min(1), times_min(3)];
            [l1, a1] = fitParabola(squeeze(ts_flipped(idx_left, :, ss)), time, times_min);
        else
            error('No clear extremum within window - exiting')
        end


        xline(l1, 'Color',"#0072BD")
        yline(a1, 'Color',"#0072BD")
        text(l1+0.01, a1-0.3, [num2str(l1) ', ' num2str(a1)], ...
            'HorizontalAlignment','left', ...
            'Color', "#0072BD", ...
            'FontSize',12);
    else % User clicked nothing
        l1 = NaN;
        a1 = NaN;
    end

    % RIGHT
    disp('Select peak in right hemisphere or press enter to skip')
    [x2_clicks, ~] = ginput(2);
    if ~isempty(x2_clicks)
        x2_start = min(x2_clicks);
        x2_end = max(x2_clicks);
        search_window_idx = time >= x2_start & time <= x2_end;

        % Extract signal in window
        signal_r = squeeze(ts_flipped(idx_right, :, ss));
        signal_window = signal_r(search_window_idx);
        time_window = time(search_window_idx);

        % Plot to visualize
        plot(time_window, signal_window, 'k', 'LineWidth', 3)

        % Find extrema in window
        is_max_window = islocalmax(signal_window);
        is_min_window = islocalmin(signal_window);

        if is_valley
            extrema = is_min_window;
        else
            extrema = is_max_window;
        end

        if sum(extrema) == 1
            % Exactly one minimum found
            idx_min = find(extrema);
            l2 = time_window(idx_min);
            a2 = signal_window(idx_min);
            disp('Local minimum found - do not fit parabola')
        elseif sum(extrema) == 2
            disp('Biphid found - fitting parabola')
            [l2, a2] = fitParabola(squeeze(ts_flipped(idx_right, :, ss)), time, time_window(extrema));
        elseif sum(extrema) == 3
            disp('Triphid found - fitting parabola')
            times_min = time_window(extrema);
            times_min = [times_min(1), times_min(3)];
            [l2, a2] = fitParabola(squeeze(ts_flipped(idx_right, :, ss)), time, times_min);
        else
            error('No clear extremum within window - exiting')
        end

        xline(l2, 'Color', "#D95319")
        yline(a2, 'Color', "#D95319")
        text(l2 + 0.01, a2 - 0.3, [num2str(l2) ', ' num2str(a2)], ...
            'HorizontalAlignment', 'left', ...
            'Color', "#D95319", ...
            'FontSize', 12);
    else
        l2 = NaN;
        a2 = NaN;
    end

    peak_data(ss, :) = [l1 a1 l2 a2];
    pause(2)
    saveas(gcf, [char(p.subject_data.subject(ss)) '.png'])
end
%%
%save("peak_data.mat", 'peak_data')

%%

function [x_peak, y_peak] = fitParabola(ts, time, peak_latency)
% Compute second order derivative
diff_ts = diff(ts, 2);
time2 = time(3:end);

% Find first bending point left from first peak
time_l = time2 < peak_latency(1);
diff_ts_l = diff_ts(time_l);
zero_crossings_l = abs(diff_ts_l) < 0.01;
bp1 = find(zero_crossings_l, 1, 'last');
bp1 = time2(bp1);

% Find first bending point right from second peak
time_r = time2 > peak_latency(2);
diff_ts_r = diff_ts(time_r);
zero_crossings_r = abs(diff_ts_r) < 0.01;
bp2 = find(zero_crossings_r, 1, 'first');
idx_r = find( time2 > peak_latency(2));
bp2 = time2(idx_r(bp2));

% Get values between bending points and peaks
left_lobe_idx = bp1 < time & time < peak_latency(1);
right_lobe_idx = peak_latency(2) < time & time < bp2;
if sum(left_lobe_idx) < 20
    left_lobe_idx(find(time < peak_latency(1), 10,"last" )) = 1;

end
if sum(right_lobe_idx) < 20
    right_lobe_idx(find(peak_latency(2) < time, 10,"first")) = 1;
end

lobes_x = time(left_lobe_idx | right_lobe_idx);
lobes_y = squeeze(ts(left_lobe_idx | right_lobe_idx));


% Fit parabola to those values
coeff = polyfit(lobes_x, lobes_y, 2);
time_win = time(find(left_lobe_idx == 1, 1,"first"):find(right_lobe_idx == 1, 1,"last"));
parabola = polyval(coeff, time_win);
plot(time_win, parabola, '--', 'LineWidth',2, 'Color',"#7E2F8E")

% Mark peak of parabola
x_peak = -coeff(2) / (2 * coeff(1));

% Find closest value in time vector and idx of corresponding element
[~, x_idx] = min(abs(time - x_peak));
x_peak = time(x_idx);
y_peak = ts(x_idx);
end