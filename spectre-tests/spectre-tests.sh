echo "=== Running Region Tracker Tests ==="
cd region-tracker
python3 eval.py ../../simulation/build/prospect-region-tracker ../../simulation/build/prospect-region-tracker

echo "=== Running Memory Tagger Tests ==="
cd ../memory-tagger
make clean && make sim INSECURE=../../simulation/build/prospect-sse-core-8 SECURE=../../simulation/build/prospect-sse-core-8
