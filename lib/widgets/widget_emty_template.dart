import 'package:flutter/material.dart';

class EmptyTemplate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width * 0.75,
      child: Card(
        elevation: 3,
        color: Colors.grey[100],
      ),
    );
  }
}
