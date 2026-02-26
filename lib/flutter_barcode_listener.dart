library flutter_barcode_listener;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef BarcodeScannedCallback = void Function(String barcode);

const Duration hundredMs = Duration(milliseconds: 100);
const String lineFeed = '\n';

class BarcodeKeyboardListener extends StatefulWidget {
  final Widget child;
  final BarcodeScannedCallback onBarcodeScanned;
  final Duration bufferDuration;

  const BarcodeKeyboardListener({
    required this.child,
    required this.onBarcodeScanned,
    this.bufferDuration = hundredMs,
    super.key,
  });

  @override
  State<BarcodeKeyboardListener> createState() =>
      _BarcodeKeyboardListenerState();
}

class _BarcodeKeyboardListenerState extends State<BarcodeKeyboardListener> {
  final List<String> _buffer = [];
  DateTime? _lastEventTime;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;

    final now = DateTime.now();

    // Clear buffer if time exceeded
    if (_lastEventTime != null &&
        now.difference(_lastEventTime!) > widget.bufferDuration) {
      _buffer.clear();
    }

    _lastEventTime = now;

    if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (_buffer.isNotEmpty) {
        widget.onBarcodeScanned(_buffer.join());
        _buffer.clear();
      }
    } else {
      if (event.character != null && event.character!.isNotEmpty) {
        _buffer.add(event.character!);
      }
    }

    return false;
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
