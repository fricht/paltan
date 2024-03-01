import 'dart:math';
import 'package:flutter/material.dart';


class NumberPicker extends StatefulWidget {
  final int? minVal;
  final int? maxVal;
  int value;
  void Function(int)? onValueChange;
  NumberPicker({super.key, this.minVal, this.maxVal, this.value = 0, this.onValueChange});

  @override
  State<NumberPicker> createState() => _NumberPickerState();
}

class _NumberPickerState extends State<NumberPicker> {

  bool atMax = false;
  bool atMin = false;

  @override
  void initState() {
    super.initState();
    postProcessValue();
  }

  void postProcessValue() {
    // clamp
    if (widget.minVal != null) {
      widget.value = max(widget.minVal!, widget.value);
    }
    if (widget.maxVal != null) {
      widget.value = min(widget.maxVal!, widget.value);
    }
    // check extreme
    if (widget.value == widget.minVal) {
      atMin = true;
    } else {
      atMin = false;
    }
    if (widget.value == widget.maxVal) {
      atMax = true;
    } else {
      atMax = false;
    }
    // call callback
    if (widget.onValueChange != null) {
      widget.onValueChange!(widget.value);
    }
  }

  void increment() {
    setState(() {
      widget.value++;
      postProcessValue();
    });
  }

  void decrement() {
    setState(() {
      widget.value--;
      postProcessValue();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: atMin ? null : decrement,
          icon: const Icon(Icons.remove),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue)
          ),
          child: Text(widget.value.toString()),
        ),
        IconButton(
          onPressed: atMax ? null : increment,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
