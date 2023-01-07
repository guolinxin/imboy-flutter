import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:imboy/component/ui/avatar.dart';
import 'package:imboy/component/webrtc/dragable.dart';
import 'package:imboy/component/webrtc/enum.dart';
import 'package:imboy/component/webrtc/session.dart';
import 'package:imboy/store/model/user_model.dart';
import 'package:niku/namespace.dart' as n;

import 'p2p_call_screen_logic.dart';

// ignore: must_be_immutable
class P2pCallScreenPage extends StatelessWidget {
  final P2pCallScreenLogic logic = Get.find<P2pCallScreenLogic>();
  final UserModel peer;
  final Map<String, dynamic> option;
  // option['media'] = video audio data

  final bool caller;
  final Function closePage;

  P2pCallScreenPage({
    Key? key,
    required this.peer,
    required this.option,
    // 主叫者，发起通话人
    this.caller = true,
    required this.closePage,
  }) : super(key: key);

  final double localWidth = 114.0;
  final double localHeight = 72.0;

  init() async {
    if (logic.connected.isTrue) {
      return;
    }
    logic.closePage = closePage;
    logic.switchRenderer = caller ? false.obs : true.obs;
    if (caller) {
      // 发起通话
      logic.invitePeer(peer.uid, option['media'] ?? 'video');
    }

    logic.onCallStateChange = (WebRTCSession s1, WebRTCCallState state) async {
      debugPrint("> rtc onCallStateChange view ${state.toString()} ${DateTime.now()}");
      switch (state) {
        case WebRTCCallState.CallStateInvite:
          logic.stateTips.value = '等待对方接受邀请...'.tr;
          break;
        case WebRTCCallState.CallStateRinging:
          // 呼入=。New + Ringing
          if (caller) {
            logic.stateTips.value = '已响铃...'.tr;
          }
          break;
        case WebRTCCallState.CallStateBye:
          logic.counter.value.cleanUp();
          logic.stateTips.value = caller ? '对方正忙...'.tr : '对方已挂断'.tr;
          if (caller && logic.connected.isTrue) {
            logic.stateTips.value = '对方已挂断'.tr;
          }
          Future.delayed(const Duration(seconds: 2), () {
            logic.connected = false.obs;
            logic.cleanUp();
          });
          break;
        case WebRTCCallState.CallStateConnected:
          logic.connectedAfter();
          debugPrint("> rtc onCallStateChange view showTool ${logic.showTool}; ${DateTime.now()}");
          break;
      }
    };
  }

  Widget _buildPeerInfo() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: Get.height * 0.3),
        child: n.Column([
          Avatar(
            imgUri: peer.avatar,
            width: 80,
            height: 80,
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 12,
              left: 12,
              right: 12,
            ),
            child: Text(
              peer.nickname,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
        ]),
      ),
    );
  }

  //tools
  Widget _buildTools() {
    return SizedBox(
      width: 200.0,
      child: n.Row(
        <Widget>[
          FloatingActionButton(
            heroTag: "switch_camera",
            onPressed: logic.switchCamera,
            child: const Icon(Icons.switch_camera),
          ),
          FloatingActionButton(
            heroTag: "call_end",
            onPressed: () {
              debugPrint("> rtc hangUp");
              logic.bye();
            },
            tooltip: 'Hangup',
            backgroundColor: Colors.pink,
            child: const Icon(Icons.call_end),
          ),
          FloatingActionButton(
            heroTag: "mic_off",
            onPressed: logic.turnMicrophone,
            child: logic.microphoneOff.value
                ? const Icon(Icons.mic_off)
                : const Icon(Icons.mic),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      ),
    );
  }

  Widget _buildDragArea() {
    return DragArea(
      child: InkWell(
        onTap: _zoom,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E6E9), width: 3),
          ),
          padding: const EdgeInsets.all(12),
          child: n.Row([
            n.Column([
              n.Row(const [
                Padding(
                  padding: EdgeInsets.only(
                    top: 4,
                    right: 4,
                  ),
                  child: Icon(
                    Icons.call,
                    color: Colors.green,
                  ),
                ),
              ])
                ..crossAxisAlignment = CrossAxisAlignment.center
                ..height = 20,
            ]),
            n.Column([
              n.Row([
                Obx(() => Text(
                      logic.counter.value.show(),
                      style: const TextStyle(
                        color: Colors.green,
                      ),
                    )),
              ]),
              n.Row(const [
                Text(
                  "正在通话",
                  style: TextStyle(color: Colors.green),
                ),
              ]),
            ]),
          ])
            ..crossAxisAlignment = CrossAxisAlignment.start,
        ),
      ),
    );
  }

  Widget _buildRemoteVideo() {
    return Positioned(
      left: 0.0,
      right: 0.0,
      top: 0.0,
      bottom: 0.0,
      child: Container(
        margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
        width: Get.width,
        height: Get.height,
        decoration: const BoxDecoration(color: Colors.black54),
        child: InkWell(
          onTap: logic.switchTools,
          child: Obx(() => RTCVideoView(
                logic.switchRenderer.isTrue
                    ? logic.remoteRenderer.value
                    : logic.localRenderer.value,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              )),
        ),
      ),
    );
  }

  Widget _buildLocalVideo(double w, double h) {
    return Obx(() => Container(
      margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
      width: logic.connected.isTrue ? w : Get.width,
      height: logic.connected.isTrue ? h : Get.height,
      child: InkWell(
        child: RTCVideoView(
              logic.switchRenderer.isTrue
                  ? logic.localRenderer.value
                  : logic.remoteRenderer.value,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              mirror: true,
            ),
        onTap: () {
          logic.switchTools();
          // 点击切换 本地和远端 RTCVideoRenderer
          if (logic.connected.isTrue) {
            logic.update([
              logic.switchRenderer.value = !logic.switchRenderer.value,
            ]);
          }
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    init();
    return Obx(() =>
        IndexedStack(index: logic.minimized.isTrue ? 1 : 0, children: [
          Scaffold(
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: logic.showTool.isTrue ? _buildTools() : null,
            body: OrientationBuilder(
              builder: (context, Orientation orientation) {
                double w = orientation == Orientation.portrait ? 90.0 : 120.0;
                double h = orientation == Orientation.portrait ? 120.0 : 90.0;

                debugPrint(
                    "> rtc build p ${logic.connected}; showTool ${logic.showTool}; logic.minimized ${logic.minimized}; w $w, h $h; x ${logic.localX}; y ${logic.localY}");

                Widget localVideo = _buildLocalVideo(w, h);
                return Stack(
                  children: <Widget>[
                    // remote video
                    _buildRemoteVideo(),

                    // local video
                    Positioned(
                      left: logic.connected.isTrue ? logic.localX.value : 0,
                      top: logic.connected.isTrue ? logic.localY.value : 0,
                      child: logic.connected.isTrue
                          ? Draggable(
                              feedback: localVideo,
                              childWhenDragging: const SizedBox.shrink(),
                              // 拖动中的回调
                              onDragEnd: (details) {
                                if (logic.connected.isTrue) {
                                  logic.localX.value = details.offset.dx;
                                  logic.localY.value = details.offset.dy;
                                  logic.localX.refresh();
                                  logic.localY.refresh();
                                }
                              },
                              child: localVideo,
                            )
                          : localVideo,
                    ),

                    if (logic.showTool.isTrue)
                      Positioned(
                        top: 30,
                        left: 8,
                        child: InkWell(
                          onTap: _zoom,
                          child: Image.asset(
                            'assets/images/chat/minization-window.png',
                            height: 32,
                          ),
                        ),
                      ),
                    if (logic.showTool.isTrue)
                      Positioned(
                        top: 40,
                        left: (Get.width - 160) / 2,
                        width: 160,
                        child: Obx(() => Text(
                              logic.stateTips.value,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            )),
                      ),

                    if (logic.connected.isFalse && logic.showTool.isTrue)
                      _buildPeerInfo(),
                  ],
                );
              },
            ),
          ),
          _buildDragArea(),
        ]));
  }

  void _zoom() {
    logic.update([
      logic.minimized.value = !logic.minimized.value,
    ]);
    debugPrint("> rtc _zoom minimized = ${logic.minimized.value}");
  }
}
