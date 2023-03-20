window.FlutterAudioLevel = {
    _timerID: null,
    _stream: null,
    stopAudioStream: () => {
        if (this._timerID) {
            clearInterval(this._timerID);
        }
        if (this._stream) {
            this._stream.getTracks().forEach(function (track) {
                track.stop();
            });
            this._stream = null;
        }
    },
    getAudioLevel: (cb) => {
        if (this._stream) {
            this.stopAudioStream();
        }
        navigator.mediaDevices.getUserMedia({ audio: true, video: false }).then((_stream) => {
            this._stream = _stream;
            const audioContext = new AudioContext();
            const mediaStreamAudioSourceNode = audioContext.createMediaStreamSource(this._stream);
            const analyserNode = audioContext.createAnalyser();
            analyserNode.fftSize = 256;
            var dataArray = new Uint8Array(analyserNode.frequencyBinCount);
            mediaStreamAudioSourceNode.connect(analyserNode);

            const _tick = () => {
                analyserNode.getByteFrequencyData(dataArray);
                let val = dataArray.reduce((a, b) => a + b, 0)
                // Get average dB level.
                var average = 20*Math.log10(Math.abs(val)/dataArray.length);
                if (cb) {
                    cb(average);
                }
            };
            this._timerID = setInterval(_tick, 50);
        });
    },
}
