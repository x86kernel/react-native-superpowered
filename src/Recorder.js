import { 
  NativeModules,
  PermissionsAndroid,
  Platform,
} from 'react-native'

const { RNSuperpowered } = NativeModules

const Recorder = {
  init: () => {
    if(Platform.OS === 'android') {
      return new Promise((resolve, reject) => {
        PermissionsAndroid.request(PermissionsAndroid.PERMISSIONS.RECORD_AUDIO)
          .then(result => {
            if(result === PermissionsAndroid.RESULTS.GRANTED || result === true)
              resolve(true);
            else
              resolve(false);
          })
      })
    }
  },
  start: ({ sampleRate, minSeconds, numChannels, applyFade } = {
    sampleRate: 48000,
    minSeconds: 0,
    numChannels: 2,
    applyFade: false,
  }) => RNSuperpowered.startRecord(sampleRate, minSeconds, numChannels, applyFade),
  stop: () => RNSuperpowered.stopRecord(),
}

export default Recorder
