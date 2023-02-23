import 'package:flutter/material.dart';

class ShiftingFit extends LayoutBuilder {
  final Widget a, b;
  ShiftingFit(this.a, this.b, {super.key})
      : super(builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth < 300) {
            return Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [a, Flexible(fit: FlexFit.loose, child: b)]));
          } else {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                    child: Align(alignment: Alignment.centerLeft, child: a)),
                Align(
                    alignment: Alignment.centerRight,
                    child: LimitedBox(
                        maxWidth: constraints.maxWidth / 1.75, child: b))
              ],
            );
          }
        });
}

const double lineBaseline = 12;
