import 'package:flutter/services.dart';

class AudioVisualizer {
  final MethodChannel channel;
  final Set<FftCallback> _fftCallbacks = new Set();
  final Set<WaveformCallback> _waveformCallbacks = new Set();

  AudioVisualizer({
    required this.channel,
  }) {
    channel.setMethodCallHandler((call) {
      switch (call.method) {
        case 'onFftVisualization':
          List<int> samples = call.arguments['fft'];
          for (Function callback in _fftCallbacks) {
            callback(samples);
          }
          break;
        case 'onWaveformVisualization':
          List<int> samples = call.arguments['waveform'];
          for (Function callback in _waveformCallbacks) {
            callback(samples);
          }
          break;
        default:
          throw new UnimplementedError(
              '${call.method} is not implemented for audio visualization channel.');
      }

      return Future.value(call.method);
    });
  }
  void activate(int sessionID) {
    print(sessionID);
    channel.invokeMethod(
        'audiovisualizer/activate_visualizer', {"sessionID": sessionID});
  }

  void deactivate() {
    channel.invokeMethod('audiovisualizer/deactivate_visualizer');
  }

  void dispose() {
    deactivate();
    _fftCallbacks.clear();
    _waveformCallbacks.clear();
  }

  void addListener({
    required FftCallback fftCallback,
    required WaveformCallback waveformCallback,
  }) {
    if (null != fftCallback) {
      _fftCallbacks.add(fftCallback);
    }
    if (null != waveformCallback) {
      _waveformCallbacks.add(waveformCallback);
    }
  }

  void removeListener({
    required FftCallback fftCallback,
    required WaveformCallback waveformCallback,
  }) {
    if (null != fftCallback) {
      _fftCallbacks.remove(fftCallback);
    }
    if (null != waveformCallback) {
      _waveformCallbacks.remove(waveformCallback);
    }
  }
}

typedef void FftCallback(List<int> fftSamples);
typedef void WaveformCallback(List<int> waveformSamples);
