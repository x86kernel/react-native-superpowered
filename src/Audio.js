import { 
  NativeModules,
} from 'react-native'

const { RNSuperpowered } = NativeModules

class Audio {
  constructor(filePath, sampleRate) {
    RNSuperpowered.initializeAudio(filePath, sampleRate)
    this._initialized = true
  }

  loadFile = (filePath) => RNSuperpowered.loadFile(filePath)

  play = () => RNSuperpowered.playAudio()
  pause = () => RNSuperpowered.pauseAudio()
  stop = () => RNSuperpowered.stopAudio()
  setPosition = (ms) => RNSuperpowered.setPosition(ms)

  setEcho = (mix) => RNSuperpowered.setEcho(mix)
  setPitchShift = (pitchShift) => RNSuperpowered.setPitchShift(pitchShift)

  process = (filePath = '') => {
    if(!filePath) {
      filePath = (Math.random() + 1).toString(36).substr(2, 10)
    }

    return RNSuperpowered.process(filePath)
  }
}

export default Audio
