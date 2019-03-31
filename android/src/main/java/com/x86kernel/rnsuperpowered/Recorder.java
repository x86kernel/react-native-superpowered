package com.x86kernel.rnsuperpowered;

import android.Manifest;
import android.util.Log;
import android.content.pm.PackageManager;
import android.support.v4.content.ContextCompat;

import com.facebook.react.bridge.ReactApplicationContext;

public class Recorder {
    private static Recorder instance = null;
    private static String tmpPath, dstPath;

    private Recorder() {}

    public static Recorder createInstance(String tmpFile, int sampleRate, int minSeconds, int numChannels, boolean applyFade) {
        if(instance != null) {
            return instance;
        }

        ReactApplicationContext context = RNSuperpoweredModule.getReactContextSingleton();

        int permissionCheck = ContextCompat.checkSelfPermission(context.getCurrentActivity(), 
                Manifest.permission.RECORD_AUDIO);

        boolean permissionGranted = permissionCheck == PackageManager.PERMISSION_GRANTED;

        if(permissionGranted) {
            System.loadLibrary("Recorder");

	        String documentDirectoryPath = RNSuperpoweredModule.getReactContextSingleton().getFilesDir().getAbsolutePath();
            tmpPath = documentDirectoryPath + "/" + tmpFile;

            initializeRecorder(tmpPath, 480, sampleRate, minSeconds, numChannels, applyFade);

            instance = new Recorder();
            return instance;
        }

        return null;
    }

    public static Recorder getInstance() {
        return instance;
    }

    public void start(String dstFile) {
        String documentDirectoryPath = RNSuperpoweredModule.getReactContextSingleton().getFilesDir().getAbsolutePath();
        dstPath = documentDirectoryPath + "/" + dstFile;

        startRecord(dstPath);
    }

    public String stop() {
        stopRecord();

        return dstPath + ".wav";
    }

    private static native void initializeRecorder(String tempPath, int bufferSize, int sampleRate, int minSeconds, int numChannels, boolean applyFade);

    private native void startRecord(String dstPath);
    private native void stopRecord();
}
