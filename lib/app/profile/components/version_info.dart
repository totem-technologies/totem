import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionInfo extends StatelessWidget {
  const VersionInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, data) {
        if (!data.hasData) return Container();
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${t.version}: ${data.hasData
                      ? '${data.data!.version} (${data.data!.buildNumber})'
                      : ""}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      },
    );
  }
}
