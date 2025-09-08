Waveform analysis is a fundamental basis of a lot of the analysis we perform in the ecosystem.

- cpu interfaces describe which signals should be interpreted
- vcd-stripper can take a vcd file (not fst) and reduce it to just the signals of interest, greatly reducing its size and speeding up further processing on it
    + if the file is vcd and bigger than 500 mb, offer this automatically (or make it a flag that is recommended)
- signal-extractor can take a (potentially stripped) vcd/fst file and return sequences of signals
    + future work: make this a yield
- compare.py takes two traces ran on the same cpu with a set of signals and returns mismatches
- profile-proteus.py takes a list of signals with signal-extractor and does some lightweight post-processing to show interesting benchmarks
- noninterference testing uses compare.py
