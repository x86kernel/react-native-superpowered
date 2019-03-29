import { 
  NativeModules,
} from 'react-native'

const { RNSuperpowered } = NativeModules

class Audio {
  constructor(filePath, sampleRate) {
    RNSuperpowered.initializeAudio(filePath, sampleRate)
  }

  play = () => {
    RNSuperpowered.playAudio()
  }

  pause = () => {
    RNSuperpowered.pauseAudio()
  }

  setEcho = (mix) => {
    RNSuperpowered.setEcho(mix)
  }

  setPitchShift = (pitchShift) => {
    RNSuperpowered.setPitchShift(pitchShift)
  }
}

export default Audio
