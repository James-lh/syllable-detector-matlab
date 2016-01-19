function nndetector_live_spmd_dsp(INPUT_DEVICE,INPUT_MAP,OUTPUT_DEVICE,OUTPUT_MAP,FS,...
    QUEUE_SIZE_INPUT,QUEUE_SIZE_OUTPUT,BUFFER_SIZE_INPUT,BUFFER_SIZE_OUTPUT)

%% SPMD DETAILS
lab_processor = 2;

%% STAGE: SETUP
samples_per_frame=round(BUFFER_SIZE_INPUT*FS);

%dsp_obj_file=dsp.AudioFileReader(TEST_FILE,'SamplesPerFrame',samples_per_frame); % for now assume left channel is audio data

fprintf('Setting up AudioRecorder on %s\n',INPUT_DEVICE);
dsp_obj_in=dsp.AudioRecorder('SampleRate',FS,'DeviceName',INPUT_DEVICE,'QueueDuration',QUEUE_SIZE_INPUT,...
  'OutputNumOverrunSamples',true,'SamplesPerFrame',samples_per_frame,'BufferSizeSource','Property',...
  'BufferSize',samples_per_frame,'NumChannels',1); %,'OutputDataType','single');

if ~isempty(INPUT_MAP)
  dsp_obj_in.ChannelMappingSource='property';
  dsp_obj_in.ChannelMapping=INPUT_MAP;
end

a = arduino('/dev/tty.usbmodem1421');
pinMode(a, 7, 'output');
a.chkp = false;
a.chks = false;

% send confirmation
if labSendReceive(lab_processor, lab_processor, 1) ~= 1
    fprintf('Setup failed\n');
    return
end

%% STAGE: LOOP
act = 0;
old_act = 0;
while ~isDone(dsp_obj_in)
    % write out pin
    if act ~= old_act
        digitalWrite(a, 7, act);
        old_act = act;
    end
    
    % read in audio
    [audio_data, noverrun] = step(dsp_obj_in);

    if noverrun>0
        fprintf('Input overrun by %d samples (%s)\n',noverrun,datestr(now));
    end
    
    % new active indicator
    act = labSendReceive(lab_processor, lab_processor, audio_data);
end


end

