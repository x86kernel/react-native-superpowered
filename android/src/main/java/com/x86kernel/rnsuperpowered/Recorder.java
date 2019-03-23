package com.x86kernel.rnsuperpowered;

import android.Manifest;
import android.util.Log;
import android.content.pm.PackageManager;
import android.support.v4.content.ContextCompat;

import com.facebook.react.bridge.ReactApplicationContext;

public class Recorder {
	private static Recorder recorderInstance;
    private String tmpFile, dstFile;

	private Recorder() {}

	public static Recorder createInstance() {
        ReactApplicationContext context = RNSuperpoweredModule.getReactContextSingleton();

        int permissionCheck = ContextCompat.checkSelfPermission(context.getCurrentActivity(), 
                Manifest.permission.RECORD_AUDIO);

    	boolean permissionGranted = permissionCheck == PackageManager.PERMISSION_GRANTED;


        if(permissionGranted) {
            System.loadLibrary("Recorder");

            recorderInstance = new Recorder();
            return recorderInstance;
        }

        return null;
	}

	public static Recorder getInstance() {
		return recorderInstance;
	}

	public void start(int sampleRate, int minSeconds, int numChannels, boolean applyFade) {
      String documentDirectoryPath = RNSuperpoweredModule.getReactContextSingleton().getFilesDir().getAbsolutePath();
      tmpFile = documentDirectoryPath + "/temp.wav";
      dstFile = documentDirectoryPath + "/audio";
      
	  StartRecord(tmpFile, dstFile, 480, sampleRate, minSeconds, numChannels, applyFade);
	}

	public String stop() {
		StopRecord();
        return dstFile + ".wav";
	}

  private native void StartRecord(String tempPath, String dstPath, int buffersize, int sampleRate, int minSeconds, int numChannels, boolean applyFade);
  private native void StopRecord();
}
