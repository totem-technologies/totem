class NetworkSample {
  final int receive;
  final int transmit;
  NetworkSample({required this.receive, required this.transmit});
}

class NetworkState {
  // giving values to the quality of the network, excellent and good are weighted
  // higher to allow for faster recovery from poor network conditions
  static const int kNetworkStateUnknown = -1;
  static const int kNetworkQualityDown = 0;
  static const int kNetworkQualityVeryBad = 1;
  static const int kNetworkQualityBad = 2;
  static const int kNetworkQualityPoor = 3;
  static const int kNetworkQualityGood = 5; //weighted 1.25
  static const int kNetworkQualityExcellent = 8; //weighted 1.6

  // samples seem to come every 2-3 or so seconds, so this is somewhere between 20 - 30 seconds
  static const int maxSamples = 10;
  static const int minSamples = 5;
  // just above poor threshold
  static const double networkQualityThreshold = 3.2;

  final List<int> _receiveQuality = [];
  final List<int> _transmitQuality = [];
  int _transmitTotal = 0;
  int _receiveTotal = 0;
  bool _transmitUnstable = false;
  bool _receiveUnstable = false;

  bool get transmitUnstable => _transmitUnstable;
  bool get receiveUnstable => _receiveUnstable;

  void addQualitySample(NetworkSample sample) {
    _receiveTotal =
        _updateNetworkQuality(_receiveQuality, _receiveTotal, sample.receive);
    double receiveAvg = _calculateAverage(_receiveQuality, _receiveTotal);
    _receiveUnstable = receiveAvg != -1 && receiveAvg < networkQualityThreshold;
    _transmitTotal = _updateNetworkQuality(
        _transmitQuality, _transmitTotal, sample.transmit);
    double transmitAvg = _calculateAverage(_transmitQuality, _transmitTotal);
    _transmitUnstable =
        transmitAvg != -1 && transmitAvg < networkQualityThreshold;
/*    debugPrint(
        'NetworkState: transmitAvg=$transmitAvg, transmitTotal=$_transmitTotal, receiveAvg=$receiveAvg, receiveTotal=$_receiveTotal'); */
  }

  int _updateNetworkQuality(
      final List<int> dataList, int total, int qualityValue) {
    if (qualityValue != kNetworkStateUnknown) {
      // Skip unknown values
      if (dataList.length == maxSamples) {
        total -= dataList.removeAt(0);
      }
      total += qualityValue;
      dataList.add(qualityValue);
    }
    return total;
  }

  double _calculateAverage(List<int> dataList, int total) {
    if (dataList.length >= minSamples) {
      return (total / dataList.length.toDouble());
    }
    return -1;
  }
}
