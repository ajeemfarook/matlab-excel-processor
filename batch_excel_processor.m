function batch_excel_processor()
%BATCH_EXCEL_PROCESSOR Batch processing pipeline for Excel files

%% ============================================================================
% CONFIGURATION SECTION
%% ============================================================================

    input_folder = 'input/';
    output_folder = 'output/';
    
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    
    plane_values = [0.45, 0.58, 0.81, 1.3];
    
    COL_AP = 43;  % Column AP
    COL_AQ = 44;  % Column AQ
    COL_T = 20;   % Column T (Left)
    COL_AK = 37;  % Column AK (Right)

%% ============================================================================
% FILE DISCOVERY
%% ============================================================================

    excel_files = dir(fullfile(input_folder, '*.xlsx'));
    num_files = length(excel_files);
    
    if num_files == 0
        error('No Excel files found in %s', input_folder);
    end
    
    fprintf('Found %d Excel file(s) to process.\n\n', num_files);

%% ============================================================================
% MAIN PROCESSING LOOP
%% ============================================================================

    for file_idx = 1:num_files
        
        current_file = excel_files(file_idx).name;
        input_path = fullfile(input_folder, current_file);
        
        [~, name_only, ~] = fileparts(current_file);
        output_filename = [name_only, '_processed.xlsx'];
        output_path = fullfile(output_folder, output_filename);
        
        fprintf('========================================\n');
        fprintf('Processing file %d/%d: %s\n', file_idx, num_files, current_file);
        fprintf('========================================\n');
        
        % --- Read Excel Data ---
        opts = detectImportOptions(input_path);
        opts.PreserveVariableNames = true;
        opts.DataRange = 'A1';
        
        fprintf('Reading data...\n');
        raw_data = readtable(input_path, opts);
        original_data = raw_data;
        
        % Store variable names (column headers) - IMPORTANT
        variable_names = raw_data.Properties.VariableNames;
        num_rows = height(raw_data);
        num_cols = width(raw_data);
        fprintf('Loaded: %d rows x %d columns\n', num_rows, num_cols);
        fprintf('Column names preserved: %d headers\n', num_cols);
        
        %% DEBUG
        fprintf('\n--- DEBUG: Checking AP and AQ columns ---\n');
        AP_raw = raw_data{:, COL_AP};
        AQ_raw = raw_data{:, COL_AQ};
        AP_data = extract_numeric_column(AP_raw);
        AQ_data = extract_numeric_column(AQ_raw);
        fprintf('AP: %d valid, AQ: %d valid\n', sum(~isnan(AP_data)), sum(~isnan(AQ_data)));
        
        %% STEP 1: DATA CLEANING
        fprintf('\nStep 1: Cleaning data...\n');
        cleaned_data = clean_numeric_values(raw_data, num_cols);
        
        %% STEP 2: PLANE SEGMENTATION
        fprintf('\nStep 2: Segmenting data by planes...\n');
        
        [segment_info, num_segments] = identify_plane_segments(...
            AP_data, AQ_data, plane_values, num_rows);
        
        % Insert separators
        cleaned_with_separators = insert_segment_separators(cleaned_data, segment_info, num_segments);
        
        fprintf('\n  === SEGMENT SUMMARY ===\n');
        fprintf('  - Found %d plane segment(s)\n', num_segments);
        for s = 1:num_segments
            fprintf('    Segment %d: Plane %.2f | Rows %d-%d | Count: %d\n', ...
                s, segment_info(s).plane_value, ...
                segment_info(s).start_row, segment_info(s).end_row, ...
                segment_info(s).end_row - segment_info(s).start_row + 1);
        end
        fprintf('  =========================\n');
        
        %% STEP 3: STATISTICAL ANALYSIS
        fprintf('\nStep 3: Computing statistics...\n');
        stats_table = compute_segment_statistics(...
            raw_data, segment_info, num_segments, COL_T, COL_AK);
        
        %% STEP 4: SAVE OUTPUT
        fprintf('\nStep 4: Saving results...\n');
        
        if exist(output_path, 'file')
            delete(output_path);
        end
        
        % Convert cell array back to table WITH variable names
        cleaned_final = cell2table(cleaned_with_separators, ...
            'VariableNames', variable_names);
        
        % Verify headers are preserved
        fprintf('    Cleaned data headers (first 5): ');
        disp(variable_names(1:min(5, end)));
        
        % Write all sheets
        writetable(original_data, output_path, 'Sheet', 'Original Data');
        writetable(cleaned_final, output_path, 'Sheet', 'Cleaned Data');
        writetable(stats_table, output_path, 'Sheet', 'Statistics');
        
        fprintf('  - Saved: %s\n', output_filename);
        fprintf('\nCOMPLETED: %s\n\n', current_file);
        
    end

    fprintf('========================================\n');
    fprintf('BATCH PROCESSING COMPLETE\n');
    fprintf('========================================\n');

end


%% ============================================================================
% SUBFUNCTIONS
%% ============================================================================

%% --------------------------------------------------------------------------
% extract_numeric_column
%% --------------------------------------------------------------------------
function numeric_arr = extract_numeric_column(col_data)
    n = length(col_data);
    numeric_arr = NaN(n, 1);
    for i = 1:n
        val = col_data(i);
        numeric_arr(i) = safe_convert_to_number(val);
    end
end

%% --------------------------------------------------------------------------
% safe_convert_to_number
%% --------------------------------------------------------------------------
function num = safe_convert_to_number(val)
    num = NaN;
    if isempty(val); return; end
    if iscell(val)
        if isempty(val); return; end
        num = safe_convert_to_number(val{1});
        return;
    end
    if isnumeric(val)
        if ~any(isnan(val)) && ~isinf(val)
            num = double(val);
        end
        return;
    end
    if ischar(val)
        val = strtrim(val);
        if isempty(val); return; end
        val = strrep(val, ',', '.');
        parsed = str2double(val);
        if ~isnan(parsed); num = parsed; end
        return;
    end
    if isstring(val)
        val = char(val);
        val = strtrim(val);
        if isempty(val); return; end
        val = strrep(val, ',', '.');
        parsed = str2double(val);
        if ~isnan(parsed); num = parsed; end
        return;
    end
    if islogical(val)
        num = double(val);
        return;
    end
end

%% --------------------------------------------------------------------------
% identify_plane_segments
%% --------------------------------------------------------------------------
function [segment_info, num_segments] = identify_plane_segments(...
    AP_data, AQ_data, plane_values, num_rows)
    
    first_occurrence = struct('plane', {}, 'row', {});
    
    for p = 1:length(plane_values)
        ap_match = find(abs(AP_data - plane_values(p)) < 1e-4, 1);
        aq_match = find(abs(AQ_data - plane_values(p)) < 1e-4, 1);
        
        valid_rows = [];
        if ~isempty(ap_match); valid_rows = [valid_rows, ap_match]; end
        if ~isempty(aq_match); valid_rows = [valid_rows, aq_match]; end
        
        if ~isempty(valid_rows)
            first_occurrence(p) = struct('plane', plane_values(p), 'row', min(valid_rows));
        end
    end
    
    if isempty(first_occurrence)
        sorted_rows = [];
        sorted_planes = [];
    else
        sorted_rows = sort([first_occurrence.row]);
        sorted_planes = zeros(size(sorted_rows));
        for i = 1:length(sorted_rows)
            for j = 1:length(first_occurrence)
                if first_occurrence(j).row == sorted_rows(i)
                    sorted_planes(i) = first_occurrence(j).plane;
                    break;
                end
            end
        end
    end
    
    fprintf('    First occurrence of each plane:\n');
    for i = 1:length(sorted_planes)
        fprintf('      Plane %.2f starts at row %d\n', sorted_planes(i), sorted_rows(i));
    end
    
    if isempty(sorted_rows)
        segment_info = struct('plane_value', {0}, 'start_row', {1}, 'end_row', {num_rows});
        num_segments = 1;
    else
        segments = struct('plane_value', {}, 'start_row', {}, 'end_row', {});
        seg_idx = 1;
        
        if sorted_rows(1) > 1
            segments(seg_idx) = struct('plane_value', 0, 'start_row', 1, 'end_row', sorted_rows(1) - 1);
            seg_idx = seg_idx + 1;
        end
        
        for i = 1:length(sorted_rows)
            if i < length(sorted_rows)
                end_row = sorted_rows(i+1) - 1;
            else
                end_row = num_rows;
            end
            segments(seg_idx) = struct('plane_value', sorted_planes(i), 'start_row', sorted_rows(i), 'end_row', end_row);
            seg_idx = seg_idx + 1;
        end
        
        segment_info = segments;
        num_segments = length(segments);
    end
end

%% --------------------------------------------------------------------------
% clean_numeric_values - Preserve ALL data exactly, only clean values
%% --------------------------------------------------------------------------
function cleaned_data = clean_numeric_values(data, num_cols)
    % Convert table to cell array for manipulation
    data_cell = table2cell(data);
    cleaned_cell = data_cell;
    
    % Process all columns (including A and B for cleaning dot->comma)
    for col = 1:num_cols
        for row = 1:size(data_cell, 1)
            cell_val = data_cell{row, col};
            
            % Replace dot with comma in string values (ALL columns)
            if ischar(cell_val)
                cleaned_cell{row, col} = strrep(cell_val, '.', ',');
            elseif isnumeric(cell_val) && ~isnan(cell_val) && ~isinf(cell_val)
                % Keep numeric values as-is
                cleaned_cell{row, col} = cell_val;
            elseif iscell(cell_val)
                % Handle cell within cell
                if ischar(cell_val{1})
                    cleaned_cell{row, col}{1} = strrep(cell_val{1}, '.', ',');
                end
            end
        end
    end
    
    % Return cell array with data only (no headers)
    cleaned_data = cleaned_cell;
end

%% --------------------------------------------------------------------------
% insert_segment_separators
%% --------------------------------------------------------------------------
function output_data = insert_segment_separators(data, segment_info, num_segments)
    if num_segments <= 1
        output_data = data;
        return;
    end
    
    output_data = data;
    n_cols = size(data, 2);
    
    % Insert empty rows from bottom to top
    for seg_idx = num_segments:-1:2
        insert_position = segment_info(seg_idx).start_row;
        
        % Create empty row as cell array
        empty_row = cell(1, n_cols);
        for c = 1:n_cols
            empty_row{c} = NaN;
        end
        
        % Insert the empty row
        output_data = [output_data(1:insert_position-1, :); 
                       empty_row; 
                       output_data(insert_position:end, :)];
    end
end

%% --------------------------------------------------------------------------
% compute_segment_statistics
%% --------------------------------------------------------------------------
function stats_table = compute_segment_statistics(...
    data, segment_info, num_segments, col_T, col_AK)
    
    var_names = {...
        'Segment', 'Plane_Value', 'Start_Row', 'End_Row', ...
        'Mean_L', 'SD_L', 'Median_L', 'Q1_L', 'Q3_L', 'IQR_L', ...
        'Mean_R', 'SD_R', 'Median_R', 'Q1_R', 'Q3_R', 'IQR_R'
    };
    
    stats_data = cell(num_segments, length(var_names));
    
    for seg_idx = 1:num_segments
        start_row = segment_info(seg_idx).start_row;
        end_row = segment_info(seg_idx).end_row;
        plane_val = segment_info(seg_idx).plane_value;
        
        if start_row > end_row || start_row < 1 || end_row > height(data)
            continue;
        end
        
        segment_data = data(start_row:end_row, :);
        
        % Get column T (Left)
        T_raw = segment_data{:, col_T};
        T_values = extract_numeric_column(T_raw(:));
        T_values = T_values(~isnan(T_values));
        
        % Get column AK (Right)
        AK_raw = segment_data{:, col_AK};
        AK_values = extract_numeric_column(AK_raw(:));
        AK_values = AK_values(~isnan(AK_values));
        
        % Statistics for Left (Column T)
        if ~isempty(T_values)
            mean_L = mean(T_values);
            sd_L = std(T_values, 0);
            median_L = median(T_values);
            q1_L = quantile(T_values, 0.25);
            q3_L = quantile(T_values, 0.75);
            iqr_L = q3_L - q1_L;
        else
            mean_L = NaN; sd_L = NaN; median_L = NaN;
            q1_L = NaN; q3_L = NaN; iqr_L = NaN;
        end
        
        % Statistics for Right (Column AK)
        if ~isempty(AK_values)
            mean_R = mean(AK_values);
            sd_R = std(AK_values, 0);
            median_R = median(AK_values);
            q1_R = quantile(AK_values, 0.25);
            q3_R = quantile(AK_values, 0.75);
            iqr_R = q3_R - q1_R;
        else
            mean_R = NaN; sd_R = NaN; median_R = NaN;
            q1_R = NaN; q3_R = NaN; iqr_R = NaN;
        end
        
        stats_data{seg_idx, 1} = seg_idx;
        stats_data{seg_idx, 2} = plane_val;
        stats_data{seg_idx, 3} = start_row;
        stats_data{seg_idx, 4} = end_row;
        stats_data{seg_idx, 5} = mean_L;
        stats_data{seg_idx, 6} = sd_L;
        stats_data{seg_idx, 7} = median_L;
        stats_data{seg_idx, 8} = q1_L;
        stats_data{seg_idx, 9} = q3_L;
        stats_data{seg_idx, 10} = iqr_L;
        stats_data{seg_idx, 11} = mean_R;
        stats_data{seg_idx, 12} = sd_R;
        stats_data{seg_idx, 13} = median_R;
        stats_data{seg_idx, 14} = q1_R;
        stats_data{seg_idx, 15} = q3_R;
        stats_data{seg_idx, 16} = iqr_R;
    end
    
    stats_table = cell2table(stats_data, 'VariableNames', var_names);
end
