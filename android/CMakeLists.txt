cmake_minimum_required(VERSION 3.4.1)

file(TO_CMAKE_PATH ${PATH_TO_SUPERPOWERED} PATH_TO_SUPERPOWERED)

include_directories(src/main/cpp)
include_directories(${PATH_TO_SUPERPOWERED})

add_library (
	SuperpoweredRecorder
	SHARED
	src/main/cpp/SuperpoweredRecorder.cpp
	${PATH_TO_SUPERPOWERED}/AndroidIO/SuperpoweredAndroidAudioIO.cpp
)

target_link_libraries (
	SuperpoweredRecorder
	log
	android
	OpenSLES
	${PATH_TO_SUPERPOWERED}/libSuperpoweredAndroid${ANDROID_ABI}.a
)
