function nndetector_live_loop_test(INPUT_DEVICE,OUTPUT_DEVICE,FS,QUEUE_SIZE_INPUT,...
  QUEUE_SIZE_OUTPUT,BUFFER_SIZE_INPUT,BUFFER_SIZE_OUTPUT,NETWORK)
% standard simulation setup, nothing connected to line in,
% put out detector and actual hits on left/right channels for line out

NETWORK.spec_params.win_overlap=NETWORK.spec_params.win_size-NETWORK.spec_params.fft_time_shift;
ring_buffer_size=...
NETWORK.spec_params.win_size+(NETWORK.spec_params.fft_time_shift*NETWORK.spec_params.time_steps-1);

% how long does it take to process?, read in this many samples per cycle

samples_per_frame=round(BUFFER_SIZE_INPUT*FS);

%dsp_obj_file=dsp.AudioFileReader(TEST_FILE,'SamplesPerFrame',samples_per_frame); % for now assume left channel is audio data

fprintf('Setting up AudioRecorder on %s\n',INPUT_DEVICE);
dsp_obj_in=dsp.AudioRecorder('SampleRate',FS,'DeviceName',INPUT_DEVICE,'QueueDuration',QUEUE_SIZE_INPUT,...
  'OutputNumOverrunSamples',true,'SamplesPerFrame',samples_per_frame,'BufferSizeSource','Property',...
  'BufferSize',samples_per_frame);

fprintf('Setting up AudioPlayer on %s\n',OUTPUT_DEVICE);
dsp_obj_out=dsp.AudioPlayer('SampleRate',FS,'DeviceName',OUTPUT_DEVICE,'QueueDuration',QUEUE_SIZE_OUTPUT,...
  'OutputNumUnderrunSamples',true);

% while condition, step through, process data, etc.

fprintf('Entering file play loop...\n');

% validate frequency and time indices (maybe preflight function?)

freq_idx=NETWORK.spec_params.freq_range_ds(1):NETWORK.spec_params.freq_range_ds(end);
layer0_size=size(NETWORK.layer_weights{1},2);

hit=ones(samples_per_frame,1);
ringbuffer=zeros(ring_buffer_size,1);

while ~isDone(dsp_obj_in)

  [audio_data,noverrun]=step(dsp_obj_in);

  if noverrun>0
    fprintf('Input overrun by %d samples\n',noverrun);
  end

  ringbuffer=[ ringbuffer(samples_per_frame+1:ring_buffer_size);audio_data(:,1) ];
  s=spectrogram(ringbuffer,NETWORK.spec_params.win_size,NETWORK.spec_params.win_overlap,NETWORK.spec_params.fft_size);

  % scale spectrogram

  s=abs(s(freq_idx,:));
  s=NETWORK.amp_scaling_fun(s);
  s=reshape(s,layer0_size,1);
  s=zscore(s);

  % flow activation

  [activation,trigger]=nndetector_live_sim_network(s,NETWORK);

  % active or inactive?

  if trigger
    outdata=[hit hit*0];
  else
    outdata=[hit*0 hit*0];
  end

  underrun=step(dsp_obj_out,outdata);

  if underrun>0
    fprintf('Output underrun by %d samples\n',underrun);
  end

end


% separate function for net?
