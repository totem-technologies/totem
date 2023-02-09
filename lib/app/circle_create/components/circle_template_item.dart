import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:totem/components/index.dart';
import 'package:totem/models/index.dart';
import 'package:totem/theme/index.dart';

class CircleTemplateItem extends StatelessWidget {
  const CircleTemplateItem({super.key, this.template, this.onPressed});
  final CircleTemplate? template;
  final Function(CircleTemplate?)? onPressed;
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return InkWell(
      onTap: onPressed != null ? () => onPressed!(template) : null,
      child: ListItemContainer(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleImage(
              circle: template,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template != null ? template!.name : t.newCircleTemplate,
                    style: Theme.of(context).textStyles.displaySmall,
                  ),
                  const SizedBox(height: 6),
                  if (template?.description != null &&
                      template!.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        template!.description!,
                        style: Theme.of(context).textStyles.bodyLarge,
                      ),
                    ),
                  if (template == null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        t.newCircleTemplateMessage,
                        style: Theme.of(context).textStyles.bodyLarge,
                      ),
                    ),
                  const SizedBox(height: 5),
                  if (template != null) ...[
                    _repeatInfo(context),
                    const SizedBox(
                      height: 4,
                    ),
                    _iconDataRow(
                        template!.isPrivate
                            ? LucideIcons.lock
                            : LucideIcons.unlock,
                        template!.isPrivate ? t.private : t.public),
                    const SizedBox(
                      height: 4,
                    ),
                    _iconDataRow(LucideIcons.clock, _timeInfo(context)),
                    const SizedBox(
                      height: 4,
                    ),
                    _iconDataRow(LucideIcons.users,
                        t.attendeeLimit(template!.maxParticipants))
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeInfo(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    if (template!.maxMinutes > 60) {
      return t.hoursAndMinsValue(
          template!.maxMinutes / 60, template!.maxMinutes % 60);
    } else if (template!.maxMinutes == 60) {
      return t.hoursValue(1);
    } else {
      return t.minsValue(template!.maxMinutes);
    }
  }

  Widget _repeatInfo(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    String sessionType = t.instantSession;
    String repeatType = t.doesNotRepeat;
    if (template!.repeating != null) {
      sessionType = t.repeatingSession;
      repeatType = template!.repeating!.toLocalizedString(t);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            sessionType,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            repeatType,
          ),
        ],
      ),
    );
  }

  Widget _iconDataRow(IconData icon, String label) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
        ),
        const SizedBox(width: 10),
        Text(
          label,
        ),
      ],
    );
  }
}
