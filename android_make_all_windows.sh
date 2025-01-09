./autogen.sh
autoconf -f

echo "Compile for armeabi-v7a architecture"
./configure --host=x86_64-windows --build=arm --with-android

make android

echo "Compile for arm64-v8a architecture"
./configure --host=x86_64-windows --build=aarch64 --with-android
make android

echo "Compile for x86 architecture"
./configure --host=x86_64-windows --build=x86 --with-android
make android

echo "Compile for x86_64 architecture"
./configure --host=x86_64-windows --build=x86_64 --with-android
make android


echo "Copy compiled files and ressources into android_project"
make android-install
