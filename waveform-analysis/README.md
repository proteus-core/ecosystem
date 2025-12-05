# Waveform analysis

## Binary tools

After installation, the library exports the following binaries that can be used (after activating the virtual environment):

- `strip-vcd`: reduce VCD files to the list of signals that we are interested in (to speed up later processing or to be able to store it)
- `waveform-correctness`: check the equivalence of architectural signals between two waveforms
- `waveform-security`: checks whether certain benchmarks, when compiled with and without different countermeasures exhibit the expected leakage

For more details, consult the `--help` option on these binaries.

## Internal detail notes

Waveform analysis is a fundamental basis of a lot of the analysis we perform in the ecosystem.

- cpu interfaces describe which signals should be interpreted
- vcd-stripper can take a vcd file (not fst) and reduce it to just the signals of interest, greatly reducing its size and speeding up further processing on it
    + if the file is vcd and bigger than 500 mb, offer this automatically (or make it a flag that is recommended)
- signal-extractor can take a (potentially stripped) vcd/fst file and return sequences of signals
    + future work: make this a yield
- compare.py takes two traces ran on the same cpu with a set of signals and returns mismatches
- profile-proteus.py takes a list of signals with signal-extractor and does some lightweight post-processing to show interesting benchmarks
- noninterference testing uses compare.py
