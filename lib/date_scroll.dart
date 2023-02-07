import 'package:flutter/material.dart';

class DateScroll extends StatefulWidget {
  const DateScroll({Key? key}) : super(key: key);

  @override
  State<DateScroll> createState() => _DateScrollState();
}

class _DateScrollState extends State<DateScroll> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      width: double.infinity,
      margin: EdgeInsets.symmetric(
          vertical: 10.0, horizontal: MediaQuery.of(context).size.width * 0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () {},
            child: const Icon(Icons.arrow_back),
          ),
          const Text('Today'),
          ElevatedButton(
            onPressed: () {},
            child: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }
}
