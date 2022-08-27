import 'dart:async';

/// 一个简单的计数器封装
///   Counter counter = Counter(start: 0);
///   启动计时器
//     counter.startTimer((Timer tm) {
//       //更新界面
//       setState(() {
//         //秒数+1，因为一秒回调一次R
//         counter.start += 1;
//       });
//       debugPrint(">>> on counter/startTimer ${counter.start}");
//     });
///
///  不要忘记了在 dispose 的时候 关闭计时器
///  counter.close();
class Counter {
  Timer? timer;
  int start = 0;
  Counter({
    this.start = 0,
  });

  String formatTime(int timeNum) {
    return timeNum < 10 ? "0" + timeNum.toString() : timeNum.toString();
  }

  String constructTime(int seconds) {
    int hour = seconds ~/ 3600;
    int minute = seconds % 3600 ~/ 60;
    int second = seconds % 60;
    return formatTime(hour) +
        ":" +
        formatTime(minute) +
        ":" +
        formatTime(second);
  }

  void startTimer(Function callback) {
    //设置 1 秒回调一次
    const period = Duration(seconds: 1);
    timer = Timer.periodic(period, (tm) {
      callback(tm);
    });
  }

  String show() {
    return constructTime(start);
  }

  void close() {
    if (timer != null) {
      timer?.cancel();
    }
  }
}
