function nndetector_live_simulate(INPUT_DEVICE,OUTPUT_DEVICE,TEST_FILE,FS,QUEUE_SIZE_OUTPUT,NETWORK)
% standard simulation setup, nothing connected to line in,
% put out detector and actual hits on left/right channels for line out

fprintf('Loading file: %s\n',TEST_FILE)
dsp_obj_file=dsp.AudioFileReader(TEST_FILE,'SamplesPerFrame',NETWORK.spec_params.win_size); % for now assume left channel is audio data

fprintf('Setting up AudioPlayer on %s\n',OUTPUT_DEVICE);
%dsp_obj_out=dsp.AudioPlayer('SampleRate',FS,'DeviceName',OUTPUT_DEVICE,'QueueDuration',QUEUE_SIZE_OUTPUT);

% while condition, step through, process data, etc.

fprintf('Entering file play loop...\n');

% validate frequency and time indices (maybe preflight function?)

freq_idx=NETWORK.spec_params.freq_range_ds(1):NETWORK.spec_params.freq_range_ds(end);

while ~isDone(dsp_obj_file)
  tic;
  audio_data=step(dsp_obj_file);

  size(audio_data)

  % scale, normalize, etc. etc.

  s=spectrogram(audio_data,NETWORK.spec_params.win_size,NETWORK.spec_params.win_shift,NETWORK.spec_params.fft_size);
  s=s(freq_idx,:);
  s=NETWORK.amp_scaling_fun(s);
  s=reshape(s,[],1);
  s=NETWORK.input_normalize(s);

  % flow activation

  [activation,trigger]=nndetector_live_sim_network(s,NETWORK);

  activation
  trigger
  toc
  
  % active or inactive?

end


% separate function for net?
