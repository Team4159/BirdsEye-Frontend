import 'package:flutter/material.dart';

class ShiftingFit extends LayoutBuilder {
  final Widget a, b;
  ShiftingFit(this.a, this.b, {super.key})
      : super(builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth < 300) {
            return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [a, b]);
          } else {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                    child: Align(alignment: Alignment.centerLeft, child: a)),
                ConstrainedBox(
                    constraints:
                        BoxConstraints(maxWidth: constraints.maxWidth / 1.75),
                    child: IntrinsicWidth(
                        child:
                            Align(alignment: Alignment.centerRight, child: b)))
              ],
            );
          }
        });
}

const double lineBaseline = 12;
