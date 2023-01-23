set -ex

# Default values.
SHARDS=1
SHARD_INDEX=0

# Parse given command for variables.
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    -n|--shards)
    SHARDS="$2"
    shift # past argument
    shift # past value
    ;;
    -i|--shard-index)
    SHARD_INDEX="$2"
    shift # past argument
    shift # past value
    ;;
esac
done

# Switch to Flutter master.
flutter channel master
flutter upgrade
flutter doctor -v

cd flutter/dev/customer_testing
dart pub get
cd ../../..

# Now run the tests a bunch of times to try to find flakes (tests that sometimes pass
# even though they should be failing).
dart flutter/dev/customer_testing/run_tests.dart --shards $SHARDS --shard-index $SHARD_INDEX --repeat=15 --skip-template --verbose registry/*.test
