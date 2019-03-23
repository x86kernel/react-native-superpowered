package com.x86kernel.rnsuperpowered;

import java.io.File;

public class Audio {
	private static Audio audioInstance;

	private Audio() {}

    public static Audio createInstance() {
        System.loadLibrary("Audio");
        audioInstance = new Audio();

        return audioInstance;
    }

    public static Audio getInstance() {
        return audioInstance;
    }

    public void loadFile(String filePath, int sampleRate) {
        File file = new File(filePath);
        long fileLength = file.length();

        if(fileLength != 0) {
            Audio(sampleRate, 480, filePath, fileLength);
        }
    }

    public void play() {
        Play();
    }

    public void pause() {
        Pause();
    }

  private native void Audio(int sampleRate, int bufferSize, String filePath, long fileLength);
  private native void Play();
  private native void Pause();
}
