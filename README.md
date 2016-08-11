# Syllable Detector - MATLAB implementation

The syllable detector is a MATLAB program that uses the DSP functionality
to perform low-latency syllable detection based on a simple neural network
trained using the [training code](https://github.com/gardner-lab/syllable-detector-learn)
created by @bwpearre. Detection events result in a TTL pulse that can be generated
either on an audio channel or via an Arduino (pin 7). For the Arduino output, see the
[arduino branch](https://github.com/gardner-lab/syllable-detector-matlab/tree/arduino).

This detector is less performant than the 
[Swift implementation](https://raw.githubusercontent.com/gardner-lab/syllable-detector-swift),
but offers a cross-platform solution with lower barriers to entry and more flexibility
for debugging. Performance an be tuned by adjusting the buffer size for input and output,
but lowering these values too much (less than 2-5ms) can result in buffer overruns and
underruns, that will hurt accuracy.

Note that the MATLAB implementation may not support all the same normalization options that are available in the training code and Swift implementation.

To start the detector, use the `nndetector_live` command. You will be prompted to
select what input and output devices to use, as well as for a ".mat" file containing
a trained detector.

You can include parameters when calling the `nndetector_live` command. For example, to
tune the audio buffer sizes to 2ms, use the following command:

```
nndetector_live('buffer_size_input', 0.002, 'buffer_size_output', 0.002);
```

This code requies the Data Acquisition Toolbox and the Parallel Computing Toolbox.

This code was created by Jeffrey Markowitz @jmarkow, and underwent minor modifications
to optimize performance (using "spmd" from the Parallel toolbox) by L. Nathan Perkins
@nathanntg.
