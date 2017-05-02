# extractMIR

extractMIR is a MATLAB script for calculating MIR (music information retrieval) features from many audio files and saving them to a csv file. It is basically a wrapper for MIR Toolbox for extracting many features from a folder of files. An existing csv file can be specified, in which case extractMIR will get the feature list from this csv file, and will not re-extract features from files that are already in the file.

## Dependencies

- [MATLAB](http://www.mathworks.com/)
- [MIR Toolbox 1.6.1](https://www.jyu.fi/hytk/fi/laitokset/mutku/en/research/materials/mirtoolbox)
- ffmpeg (command-line utility)

## Octave Support

Currently this is dependant on the MATLAB version of MIR Toolbox. It would be nice to use the [Octave implementation](https://github.com/martinarielhartmann/mirtooloct), but filtering doesn't work there which isn't ideal; for example, we can't calculate sub-band spectral flux without filtering.
