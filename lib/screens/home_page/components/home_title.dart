import 'package:flutter/material.dart';

import '../../../strings.dart';

class HomeTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16.0),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: appNameFirstString,
          style: Theme.of(context).textTheme.headline1,
          children: <TextSpan>[
            TextSpan(
                text: appNameSecondString,
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
