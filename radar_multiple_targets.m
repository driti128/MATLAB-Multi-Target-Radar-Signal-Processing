clc;
clear;
close all;

%% =========================================================
% MULTIPLE TARGET RADAR SIGNAL PROCESSING
% MATLAB Simulation
%
% Features:
% 1. LFM radar target modeling
% 2. Multiple moving targets
% 3. Range FFT
% 4. Doppler FFT
% 5. Range-Doppler map
% 6. Automatic target detection
% 7. SNR performance testing
% 8. Relative RCS / target strength modeling
% ==========================================================


%% =========================================================
% 1. RADAR PARAMETERS
% ==========================================================

c = 3e8;                    % Speed of light (m/s)
fc = 77e9;                  % Carrier frequency = 77 GHz

B = 150e6;                  % Chirp bandwidth = 150 MHz
T_chirp = 20e-6;            % Chirp duration = 20 microseconds
Fs = 20e6;                  % Sampling frequency = 20 MHz

K = B / T_chirp;            % Chirp slope
lambda = c / fc;            % Radar wavelength


%% =========================================================
% 2. NUMBER OF CHIRPS
% ==========================================================

N_chirps = 128;


%% =========================================================
% 3. TARGET INFORMATION
% ==========================================================

% Target ranges in meters
target_range = [100 200 300];

% Target velocities in m/s
target_velocity = [20 -10 5];

% Relative radar cross-section / reflection strength
%
% Target 1 = strong reflector
% Target 2 = medium reflector
% Target 3 = weak reflector

target_RCS = [1.0 0.5 0.2];

% Convert relative RCS into signal amplitude
target_amplitude = sqrt(target_RCS);

% Number of targets
N_targets = length(target_range);


%% =========================================================
% 4. TIME VECTOR
% ==========================================================

N_samples = round(T_chirp * Fs);

t_fast = (0:N_samples-1) / Fs;


%% =========================================================
% 5. TARGET DELAY
% ==========================================================

target_delay = ...
    2 * target_range / c;


%% =========================================================
% 6. TARGET DOPPLER FREQUENCY
% ==========================================================

target_doppler = ...
    2 * target_velocity / lambda;


%% =========================================================
% 7. RANGE BEAT FREQUENCY
% ==========================================================

target_beat_frequency = ...
    K .* target_delay;


%% =========================================================
% 8. DISPLAY RADAR PARAMETERS
% ==========================================================

fprintf('\n');
fprintf('====================================================\n');
fprintf('          MULTIPLE TARGET RADAR SIMULATION\n');
fprintf('====================================================\n');

fprintf('\nRADAR PARAMETERS\n');
fprintf('Carrier Frequency  = %.2f GHz\n', fc/1e9);
fprintf('Bandwidth          = %.2f MHz\n', B/1e6);
fprintf('Chirp Duration     = %.2f microseconds\n', ...
    T_chirp*1e6);
fprintf('Sampling Frequency = %.2f MHz\n', Fs/1e6);

fprintf('\nTARGET PARAMETERS\n');


for k = 1:N_targets

    fprintf('\nTarget %d\n', k);

    fprintf('Range              = %.2f m\n', ...
        target_range(k));

    fprintf('Velocity           = %.2f m/s\n', ...
        target_velocity(k));

    fprintf('Relative RCS       = %.2f\n', ...
        target_RCS(k));

    fprintf('Relative Amplitude = %.3f\n', ...
        target_amplitude(k));

    fprintf('Target Delay       = %.4f microseconds\n', ...
        target_delay(k)*1e6);

    fprintf('Doppler Frequency  = %.2f kHz\n', ...
        target_doppler(k)/1e3);

    fprintf('Beat Frequency     = %.2f MHz\n', ...
        target_beat_frequency(k)/1e6);

end


%% =========================================================
% 9. GENERATE CLEAN MULTIPLE-TARGET RADAR DATA
% ==========================================================

clean_radar_data = ...
    zeros(N_chirps, N_samples);


for chirp = 1:N_chirps

    % Slow-time index
    n = chirp - 1;

    % Initialize total received signal
    total_signal = ...
        zeros(1, N_samples);


    % ------------------------------------------------------
    % Add contribution from every target
    % ------------------------------------------------------

    for k = 1:N_targets

        % Range-dependent beat signal
        range_signal = ...
            exp(1j * 2*pi * ...
            target_beat_frequency(k) * t_fast);


        % Doppler phase progression
        doppler_signal = ...
            exp(1j * 2*pi * ...
            target_doppler(k) * n * T_chirp);


        % Target echo
        target_signal = ...
            target_amplitude(k) .* ...
            range_signal .* ...
            doppler_signal;


        % Add target echo
        total_signal = ...
            total_signal + target_signal;

    end


    % Store clean signal
    clean_radar_data(chirp,:) = ...
        total_signal;

end


%% =========================================================
% 10. ADD NOISE FOR MAIN RADAR RESULT
% ==========================================================

SNR = 15;

signal_power = ...
    mean(abs(clean_radar_data(:)).^2);

noise_power = ...
    signal_power / (10^(SNR/10));

noise = ...
    sqrt(noise_power/2) .* ...
    (randn(size(clean_radar_data)) + ...
     1j * randn(size(clean_radar_data)));


% Noisy radar data
radar_data = ...
    clean_radar_data + noise;


%% =========================================================
% 11. RANGE WINDOW
% ==========================================================

range_window = ...
    0.54 - ...
    0.46 * cos( ...
    2*pi*(0:N_samples-1)/(N_samples-1));


range_window = ...
    range_window(:).';


%% =========================================================
% 12. RANGE PROCESSING
% ==========================================================

range_data = ...
    radar_data .* range_window;


range_fft = ...
    fft(range_data, N_samples, 2);


%% =========================================================
% 13. RANGE AXIS
% ==========================================================

range_axis = ...
    (0:N_samples-1) .* ...
    (c*Fs/(2*K*N_samples));


%% =========================================================
% 14. DOPPLER WINDOW
% ==========================================================

doppler_window = ...
    0.54 - ...
    0.46 * cos( ...
    2*pi*(0:N_chirps-1)/(N_chirps-1));


doppler_window = ...
    doppler_window(:);


%% =========================================================
% 15. DOPPLER PROCESSING
% ==========================================================

doppler_data = ...
    range_fft .* doppler_window;


doppler_fft = ...
    fftshift( ...
    fft(doppler_data, N_chirps, 1), ...
    1);


%% =========================================================
% 16. DOPPLER FREQUENCY AXIS
% ==========================================================

PRF = 1 / T_chirp;


doppler_frequency = ...
    (-N_chirps/2 : N_chirps/2-1) .* ...
    (PRF/N_chirps);


%% =========================================================
% 17. VELOCITY AXIS
% ==========================================================

velocity_axis = ...
    doppler_frequency * lambda / 2;


%% =========================================================
% 18. RANGE-DOPPLER MAGNITUDE
% ==========================================================

range_doppler = ...
    abs(doppler_fft);


range_doppler_dB = ...
    20 * log10( ...
    range_doppler ./ ...
    max(range_doppler(:)) + eps);


%% =========================================================
% 19. LIMIT RANGE TO 400 METERS
% ==========================================================

range_limit = ...
    range_axis <= 400;


range_axis_plot = ...
    range_axis(range_limit);


range_doppler_plot = ...
    range_doppler_dB(:, range_limit);


%% =========================================================
% 20. RANGE-DOPPLER MAP
% ==========================================================

figure;

imagesc( ...
    range_axis_plot, ...
    velocity_axis, ...
    range_doppler_plot);

axis xy;

xlabel('Range (m)');
ylabel('Velocity (m/s)');

title('Multiple Target Range-Doppler Map');

colorbar;

grid on;

xlim([0 400]);


%% =========================================================
% 21. RANGE PROFILE
% ==========================================================

range_profile = ...
    max(range_doppler_plot, [], 1);


figure;

plot( ...
    range_axis_plot, ...
    range_profile, ...
    'LineWidth', 1.2);

xlabel('Range (m)');
ylabel('Magnitude (dB)');

title('Multiple Target Range Profile');

grid on;

xlim([0 400]);


%% =========================================================
% 22. VELOCITY PROFILE
% ==========================================================

velocity_profile = ...
    max(range_doppler_plot, [], 2);


figure;

plot( ...
    velocity_axis, ...
    velocity_profile, ...
    'LineWidth', 1.2);

xlabel('Velocity (m/s)');
ylabel('Magnitude (dB)');

title('Multiple Target Doppler / Velocity Profile');

grid on;


%% =========================================================
% 23. EXPECTED TARGET INFORMATION
% ==========================================================

fprintf('\n');
fprintf('====================================================\n');
fprintf('              EXPECTED TARGETS\n');
fprintf('====================================================\n');

for k = 1:N_targets

    fprintf( ...
        'Target %d: Range = %.0f m, Velocity = %.0f m/s, RCS = %.2f\n', ...
        k, ...
        target_range(k), ...
        target_velocity(k), ...
        target_RCS(k));

end


fprintf('\nSimulation completed successfully.\n');


%% =========================================================
% 24. AUTOMATIC TARGET DETECTION
% ==========================================================

% Detection threshold
detection_threshold = -8;


% Find points above threshold
candidate_points = ...
    range_doppler_plot > detection_threshold;


[row_indices, col_indices] = ...
    find(candidate_points);


candidate_magnitude = ...
    range_doppler_plot(candidate_points);


%% =========================================================
% 25. SORT CANDIDATES BY MAGNITUDE
% ==========================================================

[~, sort_order] = ...
    sort(candidate_magnitude, 'descend');


row_indices = ...
    row_indices(sort_order);


col_indices = ...
    col_indices(sort_order);


%% =========================================================
% 26. NON-MAXIMUM SUPPRESSION
% ==========================================================

detected_ranges = [];

detected_velocities = [];

detected_magnitudes = [];


% Minimum separation between detections
minimum_range_separation = 20;

minimum_velocity_separation = 2;


for n = 1:length(row_indices)

    current_velocity = ...
        velocity_axis(row_indices(n));


    current_range = ...
        range_axis_plot(col_indices(n));


    current_magnitude = ...
        range_doppler_plot( ...
        row_indices(n), ...
        col_indices(n));


    % First target
    if isempty(detected_ranges)

        accept_target = true;

    else

        range_difference = ...
            abs(detected_ranges - current_range);


        velocity_difference = ...
            abs(detected_velocities - ...
            current_velocity);


        accept_target = ...
            all( ...
            range_difference > ...
            minimum_range_separation | ...
            velocity_difference > ...
            minimum_velocity_separation);

    end


    % Store accepted target
    if accept_target

        detected_ranges(end+1) = ...
            current_range;

        detected_velocities(end+1) = ...
            current_velocity;

        detected_magnitudes(end+1) = ...
            current_magnitude;

    end


    % We expect three targets
    if length(detected_ranges) == N_targets
        break;
    end

end


%% =========================================================
% 27. DISPLAY AUTOMATIC DETECTION RESULTS
% ==========================================================

fprintf('\n');
fprintf('====================================================\n');
fprintf('          AUTOMATIC TARGET DETECTION\n');
fprintf('====================================================\n');


for n = 1:length(detected_ranges)

    fprintf('\nTarget %d\n', n);

    fprintf('Detected Range    = %.2f m\n', ...
        detected_ranges(n));

    fprintf('Detected Velocity = %.2f m/s\n', ...
        detected_velocities(n));

    fprintf('Peak Magnitude    = %.2f dB\n', ...
        detected_magnitudes(n));

end


%% =========================================================
% 28. AUTOMATIC DETECTION MAP
% ==========================================================

figure;

imagesc( ...
    range_axis_plot, ...
    velocity_axis, ...
    range_doppler_plot);

axis xy;

xlabel('Range (m)');
ylabel('Velocity (m/s)');

title('Automatic Target Detection');

colorbar;

grid on;

xlim([0 400]);

hold on;


% Mark detected targets
plot( ...
    detected_ranges, ...
    detected_velocities, ...
    'rx', ...
    'MarkerSize', 12, ...
    'LineWidth', 2);


% Add target labels
for n = 1:length(detected_ranges)

    text( ...
        detected_ranges(n) + 5, ...
        detected_velocities(n), ...
        sprintf('Target %d', n));

end


hold off;


%% =========================================================
% 29. SNR PERFORMANCE TEST
% ==========================================================

fprintf('\n');
fprintf('====================================================\n');
fprintf('              SNR PERFORMANCE TEST\n');
fprintf('====================================================\n');


% Test different SNR values
SNR_values = ...
    [20 15 10 5 0 -5];


% Store number of detected targets
detection_results = ...
    zeros(size(SNR_values));


for s = 1:length(SNR_values)

    current_SNR = ...
        SNR_values(s);


    %% -----------------------------------------------------
    % Add noise to CLEAN radar data
    % ------------------------------------------------------

    signal_power = ...
        mean(abs(clean_radar_data(:)).^2);


    noise_power = ...
        signal_power / ...
        (10^(current_SNR/10));


    noise = ...
        sqrt(noise_power/2) .* ...
        (randn(size(clean_radar_data)) + ...
         1j*randn(size(clean_radar_data)));


    noisy_data = ...
        clean_radar_data + noise;


    %% -----------------------------------------------------
    % Range processing
    % ------------------------------------------------------

    range_data_test = ...
        noisy_data .* range_window;


    range_fft_test = ...
        fft( ...
        range_data_test, ...
        N_samples, ...
        2);


    %% -----------------------------------------------------
    % Doppler processing
    % ------------------------------------------------------

    doppler_data_test = ...
        range_fft_test .* ...
        doppler_window;


    doppler_fft_test = ...
        fftshift( ...
        fft( ...
        doppler_data_test, ...
        N_chirps, ...
        1), ...
        1);


    %% -----------------------------------------------------
    % Magnitude
    % ------------------------------------------------------

    test_map = ...
        abs(doppler_fft_test);


    test_map_dB = ...
        20 * log10( ...
        test_map ./ ...
        max(test_map(:)) + eps);


    %% -----------------------------------------------------
    % Detection threshold
    % ------------------------------------------------------

    threshold = -8;


    %% -----------------------------------------------------
    % Check expected target locations
    % ------------------------------------------------------

    detection_count = 0;


    for k = 1:N_targets

        expected_range = ...
            target_range(k);


        expected_velocity = ...
            target_velocity(k);


        % Find closest range bin
        [~, range_index] = ...
            min( ...
            abs(range_axis - ...
            expected_range));


        % Find closest velocity bin
        [~, velocity_index] = ...
            min( ...
            abs(velocity_axis - ...
            expected_velocity));


        local_value = ...
            test_map_dB( ...
            velocity_index, ...
            range_index);


        if local_value > threshold

            detection_count = ...
                detection_count + 1;

        end

    end


    detection_results(s) = ...
        detection_count;


    fprintf('\nSNR = %d dB\n', ...
        current_SNR);


    fprintf('Targets detected = %d / %d\n', ...
        detection_count, ...
        N_targets);

end


%% =========================================================
% 30. SNR PERFORMANCE GRAPH
% ==========================================================

figure;

plot( ...
    SNR_values, ...
    detection_results, ...
    '-o', ...
    'LineWidth', 2);


xlabel('SNR (dB)');

ylabel('Number of Detected Targets');

title('Radar Detection Performance vs SNR');

grid on;


ylim([0 N_targets + 1]);


xlim([ ...
    min(SNR_values)-2, ...
    max(SNR_values)+2]);


%% =========================================================
% 31. SNR PERFORMANCE TABLE
% ==========================================================

fprintf('\n');
fprintf('====================================================\n');
fprintf('             SNR PERFORMANCE SUMMARY\n');
fprintf('====================================================\n');

fprintf( ...
    'SNR (dB)       Detected Targets\n');

fprintf( ...
    '--------------------------------\n');


for s = 1:length(SNR_values)

    fprintf( ...
        '%3d            %d / %d\n', ...
        SNR_values(s), ...
        detection_results(s), ...
        N_targets);

end


fprintf('\nSNR testing completed successfully.\n');


%% =========================================================
% 32. RCS SUMMARY
% ==========================================================

fprintf('\n');
fprintf('====================================================\n');
fprintf('             RCS / TARGET STRENGTH SUMMARY\n');
fprintf('====================================================\n');


for k = 1:N_targets

    fprintf( ...
        'Target %d: Range = %3.0f m | Velocity = %6.1f m/s | Relative RCS = %.2f\n', ...
        k, ...
        target_range(k), ...
        target_velocity(k), ...
        target_RCS(k));

end


fprintf('\nRCS modeling completed successfully.\n');
%% =========================================================
% 33. RCS / TARGET STRENGTH COMPARISON
% ==========================================================

figure;

bar(1:N_targets, target_RCS);

xlabel('Target Number');
ylabel('Relative RCS');

title('Relative Radar Cross-Section of Targets');

grid on;

xticks(1:N_targets);

xticklabels({'Target 1','Target 2','Target 3'});

ylim([0 1.2]);