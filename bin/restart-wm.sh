#/bin/bash

set +e

killall -9 khd
brew services restart kwm
bash -c "nohup khd &"

# to return 0
echo "Done"
