function Test = nhtsa2mat(zipfile, varargin)

%% 13/09/2018, A. Patrucco
% Converts NHTSA EV5 ascii zip files into an organized, structured Matlab
% data according to the originally documented file structure. The function
% supports a second argument (output file), which the struct, named Test,
% will be saved to if not empty.



if length(varargin) >= 1
    OutFileName = varargin{1};
else
    OutFileName = [];
end



FolderName = ['.', filesep, 'temp00'];
if strcmp(zipfile(end-2:end), 'zip')
    mkdir(FolderName);
    unzip(zipfile, FolderName);
else
    error('Error: File extension must be zip.');
end


HeaderExt = 'EV5';
head_dir = dir([FolderName, filesep, '*.', HeaderExt]);
if not(isempty(head_dir))
  try
    HeaderPath = [head_dir(1).folder, filesep, head_dir(1).name];
    catch
    HeaderPath = [FolderName, filesep, head_dir(1).name];
    end
end


% Define the output main structure
Info = struct('Test', [], 'Vehicle', [], 'Barrier', [], 'Occupant', [], ...
    'Restraint', [], 'Instrumentation', []);

nl = sprintf('\n');
vl = '|';

Empty_test = struct('VERNO', '', 'TITLE', '', 'TSTOBJ', '', 'TSTDAT', '', ...
    'TSTPRF', '', 'CONNO', '', 'TSTREF', '', 'TSTTYP', '', 'TSTCNF', '', 'TKSURF', '', ...
    'TKCOND', '', 'TEMP', '', 'RECTYP', '', 'LINK', '', 'CLSSPD', '', ...
    'IMPANG', '', 'OFFSET', '', 'IMPPNT', '', 'TOTCRV', '', ...
    'TSTCOM', '');
NF_test = length(fieldnames(Empty_test));

Empty_vehicle = struct('VEHNO', '', 'MAKE', '', 'MODEL', '', 'YEAR', '', ...
    'NHTSANO', '', 'BODY', '', 'VIN', '', 'ENGINE', '', 'ENGDSP', '', ...
    'TRANSM', '', 'VEHTWT', '', 'CURBWT', '', 'WHLBAS', '', 'VEHLEN', '', ...
    'VEHWID', '', 'VEHCG', '', 'STRSEP', '', 'COLMEC', '', 'MODIND', '', ...
    'MODDSC', '', 'BX1', '', 'BX2', '', 'BX3', '', 'BX4', '', 'BX5', '', ...
    'BX6', '', 'BX7', '', 'BX8', '', 'BX9', '', 'BX10', '', 'BX11', '', ...
    'BX12', '', 'BX13', '', 'BX14', '', 'BX15', '', 'BX16', '', ...
    'BX17', '', 'BX18', '', 'BX19', '', 'BX20', '', 'BX21', '', ...
    'VEHSPD', '', 'CRBANG', '', 'PDOF', '', 'BMPENG', '', 'SILENG', '', ...
    'APLENG', '', 'DPD1', '', 'DPD2', '', 'DPD3', '', 'DPD4', '', ...
    'DPD5', '', 'DPD6', '', 'VDI', '', 'LENCNT', '', 'DAMDST', '', ...
    'CRHDST', '', 'AX1', '', 'AX2', '', 'AX3', '', 'AX4', '', 'AX5', '', ...
    'AX6', '', 'AX7', '', 'AX8', '', 'AX9', '', 'AX10', '', 'AX11', '', ...
    'AX12', '', 'AX13', '', 'AX14', '', 'AX15', '', 'AX16', '', 'AX17', '', ...
    'AX18', '', 'AX19', '', 'AX20', '', 'AX21', '', 'CARANG', '', ...
    'VEHOR', '', 'VEHCOM', '');



NF_vehicle = length(fieldnames(Empty_vehicle));

Empty_barrier = struct('BARRIG', '', 'BARSHP', '', 'BARANG', '', ...
    'BARDIA', '', 'BARCOM', '');
NF_barrier = length(fieldnames(Empty_barrier));

Empty_occupant = struct('VEHNO', '', 'OCCLOC', '', 'OCCTYP', '', ...
    'OCCAGE', '', 'OCCSEX', '', 'OCCHT', '', 'OCCWT', '', 'MTHCAL', '', ...
    'DUMMSIZ', '', 'DUMMAN', '', 'DUMMOD', '', 'DUMDSC', '', 'HH', '', ...
    'HW', '', 'HR', '', 'HS', '', 'CD', '', 'CS', '', 'AD', '', 'HD', '', ...
    'KD', '', 'HB', '', 'NB', '', 'CB', '', 'KB', '', 'SEPOSN', '', ...
    'CNTRH1', '', 'CNTRH2', '', 'CNTRC1', '', 'CNTRC2', '', ...
    'CNTRL1', '', 'CNTRL2', '', 'HIC', '', 'T1', '', 'T2', '', ...
    'CLIP3M', '', 'LFEM', '', 'RFEM', '', 'CSI', '', 'LBELT', '', ...
    'SBELT', '', 'TTI', '', 'PELVG', '', 'OCCCOM', '');
NF_occupant = length(fieldnames(Empty_occupant));

Empty_restraint = struct('VEHNO', '', 'OCCLOC', '', 'RSTNO', '', 'RSTTYP', '', ...
    'RSTMNT', '', 'DEPLOY', '', 'RSTCOM', '');
NF_restraint = length(fieldnames(Empty_restraint));

Empty_instrumentation = struct('VEHNO', '', 'CURNO', '', 'SENTYP', '', ...
    'SENLOC', '', 'SENATT', '', 'AXIS', '', 'XUNITS', '', 'YUNITS', '', ...
    'PREFIL', '', 'INSMAN', '', 'CALDAT', '', 'INSRAT', '', 'CHLMAX', '', ...
    'INIVEL', '', 'NFP', '', 'NLP', '', 'DELT', '', 'DASTAT', '', ...
    'CHSTAT', '', 'INSCOM', '');
NF_instrumentation = length(fieldnames(Empty_instrumentation));


STR_start           = '----- EV5 -----';
STR_end             = '----- END -----';
STR_test            = '----- TEST -----';
STR_vehicle         = '----- VEHICLE -----';
STR_barrier         = '----- BARRIER -----';
STR_occupant        = '----- OCCUPANT -----';
STR_restraint       = '----- RESTRAINT -----';
STR_instrumentation = '----- INSTRUMENTATION -----';

f = fopen(HeaderPath, 'r');
s = fscanf(f, '%c');
fclose(f);

i_start = strfind(s, STR_start);
i_end = strfind(s, STR_end);
i_test = strfind(s, STR_test);
i_vehicle = strfind(s, STR_vehicle);
i_barrier = strfind(s, STR_barrier);
i_occupant = strfind(s, STR_occupant);
i_restraint = strfind(s, STR_restraint);
i_instrumentation = strfind(s, STR_instrumentation);

has_barrier = not(isempty(i_barrier));
has_occupant = not(isempty(i_occupant));
has_restraint = not(isempty(i_restraint));

i_cards = [i_start i_end i_test i_vehicle i_barrier i_occupant ...
    i_restraint i_instrumentation];

ii_start = [i_start + length(STR_start), nextcard(i_start, i_cards)];
ii_end = [i_end + length(STR_end), nextcard(i_end, i_cards)];
ii_test = [i_test + length(STR_test), nextcard(i_test, i_cards)];
ii_vehicle = [i_vehicle + length(STR_vehicle), nextcard(i_vehicle, i_cards)];
if has_barrier
    ii_barrier = [i_barrier + length(STR_barrier), nextcard(i_barrier, i_cards)];
end
if has_occupant
    ii_occupant = [i_occupant + length(STR_occupant), nextcard(i_occupant, i_cards)];
end
if has_restraint
    ii_restraint = [i_restraint + length(STR_restraint), nextcard(i_restraint, i_cards)];
end
ii_instrumentation = [i_instrumentation + length(STR_instrumentation), ...
    nextcard(i_instrumentation, i_cards)];

% Separated parser for each of the structures in the file.
% TEST.
test_line = indexes2lines(ii_test);
% Check it is only one
if not(length(test_line)) == 1
    Test = [];
    warning('Test descriptions lines are either none or more than one. Skipping.');
else
    Test = Empty_test;
    test_field = lines2fields(test_line{1});
    if length(test_field) == NF_test
        ftest = fieldnames(Test);
        for i_field = 1:length(ftest)
            Test.(ftest{i_field}) = test_field{i_field};
        end
    else
        warning('Test fields are either too few or too many. Skipping.');
        Test = [];
    end
end

% Vehicle. They can be more than one.
vehicle_lines = indexes2lines(ii_vehicle);
if isempty(vehicle_lines)
    warning('Vehicle line(s) appear to be empty. Skipping.');
    Vehicle = [];
else
    Vehicle = [];
    for iv = 1:length(vehicle_lines)
        This_vehicle = Empty_vehicle;
        thisline = vehicle_lines{iv};
        vehicle_fields = lines2fields(thisline);
        if NF_vehicle == length(vehicle_fields)
            fveh = fieldnames(This_vehicle);
            for i_field = 1:length(fveh)
                This_vehicle.(fveh{i_field}) = vehicle_fields{i_field};
            end
            if isempty(Vehicle)
                Vehicle = This_vehicle;
            else
                Vehicle = [Vehicle; This_vehicle];
            end
        else
            warning('Vehicle fields are either too few or too many. Skipping.');
            Vehicle = [];
        end
    end
end

% Barrier. They can be more than one.
if has_barrier
    barrier_lines = indexes2lines(ii_barrier);
    if isempty(barrier_lines)
        warning('Barrier line(s) appear to be empty. Skipping.');
        Barrier = [];
    else
        Barrier = [];
        for iv = 1:length(barrier_lines)
            This_barrier = Empty_barrier;
            thisline = barrier_lines{iv};
            barrier_fields = lines2fields(thisline);
            if NF_barrier == length(barrier_fields)
                fveh = fieldnames(This_barrier);
                for i_field = 1:length(fveh)
                    This_barrier.(fveh{i_field}) = barrier_fields{i_field};
                end
                if isempty(Barrier)
                    Barrier = This_barrier;
                else
                    Barrier = [Barrier; This_barrier];
                end
            else
                warning('Barrier fields are either too few or too many. Skipping.');
                Barrier = [];
            end
        end
    end
end

% Occupant. They can be more than one.
if has_occupant
    occupant_lines = indexes2lines(ii_occupant);
    if isempty(occupant_lines)
        warning('Occupant line(s) appear to be empty. Skipping.');
        Occupant = [];
    else
        Occupant = [];
        for iv = 1:length(occupant_lines)
            This_occupant = Empty_occupant;
            thisline = occupant_lines{iv};
            occupant_fields = lines2fields(thisline);
            if NF_occupant == length(occupant_fields)
                fveh = fieldnames(This_occupant);
                for i_field = 1:length(fveh)
                    This_occupant.(fveh{i_field}) = occupant_fields{i_field};
                end
                if isempty(Occupant)
                    Occupant = This_occupant;
                else
                    Occupant = [Occupant; This_occupant];
                end
            else
                warning('Occupant fields are either too few or too many. Skipping.');
                Occupant = [];
            end
        end
    end
end

% Restraint. They can be more than one.
if has_restraint
    restraint_lines = indexes2lines(ii_restraint);
    if isempty(restraint_lines)
        warning('Restraint line(s) appear to be empty. Skipping.');
        Restraint = [];
    else
        Restraint = [];
        for iv = 1:length(restraint_lines)
            This_restraint = Empty_restraint;
            thisline = restraint_lines{iv};
            restraint_fields = lines2fields(thisline);
            if NF_restraint == length(restraint_fields)
                fveh = fieldnames(This_restraint);
                for i_field = 1:length(fveh)
                    This_restraint.(fveh{i_field}) = restraint_fields{i_field};
                end
                if isempty(Restraint)
                    Restraint = This_restraint;
                else
                    Restraint = [Restraint; This_restraint];
                end
            else
                warning('Restraint fields are either too few or too many. Skipping.');
                Restraint = [];
            end
        end
    end
end

% Instrumentation. They can be more than one.
instrumentation_lines = indexes2lines(ii_instrumentation);
if isempty(instrumentation_lines)
    warning('Instrumentation line(s) appear to be empty. Skipping.');
    Instrumentation = [];
else
    Instrumentation = [];
    for iv = 1:length(instrumentation_lines)
        This_instrumentation = Empty_instrumentation;
        thisline = instrumentation_lines{iv};
        instrumentation_fields = lines2fields(thisline);
        if NF_instrumentation == length(instrumentation_fields)
            fveh = fieldnames(This_instrumentation);
            for i_field = 1:length(fveh)
                This_instrumentation.(fveh{i_field}) = instrumentation_fields{i_field};
            end
            if isempty(Instrumentation)
                Instrumentation = This_instrumentation;
            else
                Instrumentation = [Instrumentation; This_instrumentation];
            end
        else
            warning('Instrumentation fields are either too few or too many. Skipping.');
            Instrumentation = [];
        end
    end
end


Info.Test = Test;
Info.Vehicle = Vehicle;
if has_barrier
    Info.Barrier = Barrier;
end
if has_occupant
    Info.Occupant = Occupant;
end
if has_restraint
    Info.Restraint = Restraint;
end
Info.Instrumentation = Instrumentation;


% Actually reading the separate files in the folder.
NI = length(Info.Instrumentation);
for ii = 1:NI
    curve_no = Info.Instrumentation(ii).CURNO;
    while length(curve_no) < 3
        curve_no = ['0', curve_no];
    end
    CurveExt = curve_no;
    curve_dir = dir([FolderName, filesep, '*.', CurveExt]);
    if not(isempty(curve_dir))
        CurvePath = [FolderName, filesep, curve_dir(1).name];
        curvematrix = dlmread(CurvePath);
        Info.Instrumentation(ii).x = curvematrix(:, 1);
        Info.Instrumentation(ii).y = curvematrix(:, 2);
    else
        warning(['No files with ', CurveExt, ' extension found. Skipping']);
    end
end

Test = Info;

rmdir(FolderName, 's');
if not(isempty(OutFileName))
    save(OutFileName, 'Test');
end


% subfunctions
    function nc = nextcard(ic, iv)
        ncs = iv(iv > ic);
        if not(isempty(ncs))
            nc = min(ncs);
        else
            nc = [];
        end
    end


    function l_cell = indexes2lines(indexes)
        if length(indexes) == 2
            ss = s(indexes(1):indexes(2));
            nli = find(ss == nl);
            l_cell = repmat({''}, length(nli) - 1, 1);
            for iline = 1:length(nli) - 1
                ssc = ss(nli(iline) + 1:nli(iline + 1) - 1);
                l_cell{iline} = ssc;
            end
        else
            l_cell = {};
        end
    end

    function field_cell = lines2fields(lin)
        vli = find(lin == vl);
        if not(isempty(vli))
            vli = [0 vli length(lin) + 1];
            field_cell = repmat({''}, length(vli) - 1, 1);
            for ifield = 1:length(vli) - 1
                field_cell{ifield} = lin(vli(ifield) + 1:vli(ifield + 1) - 1);
            end
        else
            field_cell = {};
        end
    end

end

