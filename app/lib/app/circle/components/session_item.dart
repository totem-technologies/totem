import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:totem/components/widgets/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/app_theme_styles.dart';

class SessionItem extends StatelessWidget {
  const SessionItem({Key? key, required this.session}) : super(key: key);
  final Session session;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd();
    final timeFormat = DateFormat("h:mm a");
    final textStyles = Theme.of(context).textStyles;
    return ListItemContainer(
      child: Row(
        children: [
          Expanded(
            child: Text(
              dateFormat.format(session.scheduledDate) +
                  " @ " +
                  timeFormat.format(session.scheduledDate),
              style: textStyles.headline4,
            ),
          ),
        ],
      ),
    );
  }
}
