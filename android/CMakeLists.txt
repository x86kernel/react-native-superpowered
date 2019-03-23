cmake_minimum_required(VERSION 3.4.1)

file(TO_CMAKE_PATH ${PATH_TO_SUPERPOWERED} PATH_TO_SUPERPOWERED)

include_directories(src/main/cpp)
include_directories(${PATH_TO_SUPERPOWERED})

add_library (
	Recorder
	SHARED
	src/main/cpp/Recorder.cpp
	${PATH_TO_SUPERPOWERED}/AndroidIO/SuperpoweredAndroidAudioIO.cpp
)

add_library (
	Audio
	SHARED
	src/main/cpp/Audio.cpp
	${PATH_TO_SUPERPOWERED}/AndroidIO/SuperpoweredAndroidAudioIO.cpp
)

target_link_libraries (
	Recorder
	log
	android
	OpenSLES
	${PATH_TO_SUPERPOWERED}/libSuperpoweredAndroid${ANDROID_ABI}.a
)

target_link_libraries (
	Audio
	log
	android
	OpenSLES
	${PATH_TO_SUPERPOWERED}/libSuperpoweredAndroid${ANDROID_ABI}.a
)
