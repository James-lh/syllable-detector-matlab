function net=nndetector_live_load_net(net_file)
load(net_file);
net.userdata.fft_size = fft_size;
net.userdata.win_size = fft_size;
net.userdata.fft_time_shift = fft_time_shift;
net.userdata.amp_scaling = 'linear';
net.userdata.inp_scaling = 'zscore';
net.userdata.freq_range = [1000 8000];
net.userdata.freq_range_ds = freq_range_ds;
net.userdata.trigger_thresholds = trigger_thresholds;
net.userdata.time_window_steps = time_window_steps;
net.userdata.time_window = time_window_steps;
end