cd ../waveform-analysis
source .venv/bin/activate
cd ../tagger-tests/
echo "Running tests for granularity 8"
make GRAN=8 clean > /dev/null && make GRAN=8 sim-all SIM=../simulation/build/prospect-sse-core-8
echo "Running tests for granularity 16"
make GRAN=16 clean > /dev/null && make GRAN=16 sim-all SIM=../simulation/build/prospect-sse-core-16
echo "Running tests for granularity 32"
make GRAN=32 clean > /dev/null && make GRAN=32 sim-all SIM=../simulation/build/prospect-sse-core-32
cd ..
deactivate
