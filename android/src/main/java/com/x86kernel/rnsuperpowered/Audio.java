package com.x86kernel.rnsuperpowered;

import java.io.File;

import com.facebook.react.bridge.ReactApplicationContext;

public class Audio {
	private static Audio instance = null;

	private Audio() {}

    public static Audio createInstance(int sampleRate) {
        System.loadLibrary("Audio");

        initializeAudio(sampleRate, 480);

        if(instance != null) {
            return instance;
        }

        instance = new Audio();

        return instance;
    }

    public static Audio getInstance() {
        return instance;
    }

    public void loadFile(String filePath) {
        File file = new File(filePath);
        long fileLength = file.length();

        if(fileLength != 0) {
            loadFile(filePath, fileLength);
        }
    }

    public String processToFile(String filePath) {
        ReactApplicationContext context = RNSuperpoweredModule.getReactContextSingleton();
	    String documentDirectoryPath = RNSuperpoweredModule.getReactContextSingleton().getFilesDir().getAbsolutePath();

        String outputFilePath = documentDirectoryPath + "/" + filePath + ".wav";

        process(outputFilePath);

        return outputFilePath;
    }

    static native void initializeAudio(int sampleRate, int bufferSize);

    private native void loadFile(String filePath, long fileLength);

    public native void play();
    public native void pause();

    public native void setEcho(float mix);
    public native void setPitchShift(int pitchShift);

    private native boolean process(String filePath);
}
