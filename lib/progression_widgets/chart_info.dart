import 'package:flutter/material.dart';

class ChartInfo extends StatelessWidget {
  const ChartInfo({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.15,
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.fromLTRB(
        MediaQuery.of(context).size.width * 0.1,
        0,
        0,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text.rich(
            TextSpan(
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(
                      Icons.circle,
                      color: Colors.deepPurple,
                      size: 50,
                    ),
                  ),
                  WidgetSpan(child: SizedBox(width: 10)),
                  TextSpan(text: 'Primary muscle group')
                ]),
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(
                      Icons.circle,
                      color: Colors.deepPurple[300],
                      size: 50,
                    ),
                  ),
                  const WidgetSpan(child: SizedBox(width: 10)),
                  const TextSpan(text: 'Secondary muscle group'),
                ]),
          ),
        ],
      ),
    );
  }
}
