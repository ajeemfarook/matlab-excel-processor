function split_stats_to_sheets()
%SPLIT_STATS_TO_SHEETS  Stack segment rows from ALL processed files into
%   one workbook with one sheet per segment (Segment_1, Segment_2, ...).

    input_folder  = 'input/';
    output_folder = 'output/processed/';
    output_file   = fullfile(output_folder, 'all_segment.xlsx');

    if ~exist(input_folder, 'dir')
        error('Input folder "%s" not found.', input_folder);
    end
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end

    files = dir(fullfile(input_folder, '*_processed.xlsx'));
    if isempty(files)
        error('No *_processed.xlsx files found in %s', input_folder);
    end

    fprintf('Found %d processed file(s).\n\n', numel(files));

    buckets     = {};
    var_names   = {};
    segment_ids = [];

    for k = 1:numel(files)
        src_path = fullfile(input_folder, files(k).name);
        fprintf('Reading %3d/%d: %s\n', k, numel(files), files(k).name);

        try
            stats = readtable(src_path, 'Sheet', 'Statistics', ...
                              'VariableNamingRule', 'preserve');
        catch err
            warning('Skip %s: %s', files(k).name, err.message);
            continue;
        end

        if isempty(var_names)
            var_names = ['Source_File'; stats.Properties.VariableNames(:)];
        end

        n = height(stats);
        for s = 1:n
            row_cells = table2cell(stats(s, :));
            seg_id    = int32(stats.Segment(s));

            idx = find(segment_ids == seg_id, 1);
            if isempty(idx)
                segment_ids(end+1, 1) = seg_id;
                buckets{end+1, 1}     = {};
                idx = numel(segment_ids);
            end

            buckets{idx}(end+1, :) = [{files(k).name}, row_cells];
        end
    end

    if isempty(buckets)
        error('No segment data collected. Check input files.');
    end

    [segment_ids, sort_idx] = sort(segment_ids);
    buckets = buckets(sort_idx);

    if exist(output_file, 'file')
        delete(output_file);
    end

    fprintf('\nWriting %d segment sheet(s) to: %s\n', numel(buckets), output_file);

    for b = 1:numel(buckets)
        sheet_name = sprintf('Segment_%d', segment_ids(b));
        rows       = buckets{b};
        if isempty(rows)
            continue;
        end
        out = cell2table(rows, 'VariableNames', var_names);
        writetable(out, output_file, 'Sheet', sheet_name);
        fprintf('  %s -> %d rows\n', sheet_name, height(out));
    end

    fprintf('\nDONE.\n');
end