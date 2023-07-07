// import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VnCounter extends ValueNotifier<int> {
  VnCounter() : super(0);

  void increment() => value++;
  void decrement() => value--;
  void reset() => value = 0;
}

class ValueListenableTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counter = VnCounter();

    return Scaffold(
      appBar: AppBar(
          title: Text('ValueListenableProvider'),
          backgroundColor: Theme.of(context).highlightColor),
      body: ValueListenableProvider<int>.value(
        value: counter,
        child: _CounterText(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: counter.increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CounterText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final number = Provider.of<int>(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('ChangeNotifier には使えない。'),
          Text('下位の Widget に伝わるのは ValueNotifier.value の中身'),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(number.toString()),
          ),
        ],
      ),
    );
  }
}
