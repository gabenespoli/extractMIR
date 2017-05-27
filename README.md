# extractMIR

extractMIR is a MATLAB script for calculating MIR (music information retrieval) features from many audio files and saving them to a csv file. It is basically a wrapper for MIR Toolbox for extracting many features from a folder of files. An existing csv file can be specified, in which case extractMIR will get the feature list from this csv file, and will not re-extract features from files that are already in the file.

## Dependencies

- [MATLAB](http://www.mathworks.com/)
- Statistics and Machine Learning Toolbox
- [MIR Toolbox 1.6.1](https://www.jyu.fi/hytk/fi/laitokset/mutku/en/research/materials/mirtoolbox)
- ffmpeg (command-line utility)

### Make sure ffmpeg is in the MATLAB shell path

When MATLAB starts, it resets the \$PATH environment variable to /usr/bin:/bin:/usr/sbin:/sbin for some reason. This means that third-party utilities (like ffmpeg) are not accessible from the shell escape in matlab (i.e., the `system` command). To change this \$PATH variable, you have to edit the matlab executable in MATLAB/bin/matlab. Add something like the following to the top of that file, pointing to the folder containing ffmpeg:

`export PATH=$PATH:/usr/local/bin`

Note that if you start MATLAB from a shell with the -nodesktop option, the `$PATH` variable in the above command will actually be your `$PATH` variable from the current shell, and will thus already contain all of the modifications you may have made to that variable, for example in your .bashrc file.

## Octave Support

Currently this is dependant on the MATLAB version of MIR Toolbox. It would be nice to use the [Octave implementation](https://github.com/martinarielhartmann/mirtooloct), but filtering doesn't work there which isn't ideal; for example, we can't calculate sub-band spectral flux without filtering.
