window.AudioLevels = {
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
            var bufferLength = analyserNode.frequencyBinCount;
            console.log(bufferLength);
            var dataArray = new Float32Array(bufferLength);
            mediaStreamAudioSourceNode.connect(analyserNode);

            const _tick = () => {
                analyserNode.getFloatFrequencyData(dataArray);
                dataArray.sort();
                var min = dataArray[0] + 140;
                var max = dataArray[dataArray.length-1] + 140;
                var mean = 0.5 * (Math.abs(min) + Math.abs(max));
                if (cb) {
                    cb(mean);
                }
            };
            this._timerID = setInterval(_tick, 100);
        });
    },
}
