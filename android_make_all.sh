./autogen.sh
autoconf -f

echo "Compile for armeabi-v7a architecture"
./configure --host=x86_64-darwin --build=arm --with-android
make android

echo "Compile for arm64-v8a architecture"
./configure --host=x86_64-darwin --build=aarch64 --with-android
make android

echo "Compile for x86 architecture"
./configure --host=x86-darwin --build=x86 --with-android
make android

echo "Compile for x86_64 architecture"
./configure --host=x86_64-darwin --build=x86 --with-android
make android
