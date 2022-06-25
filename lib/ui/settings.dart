import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:libra/endpoints.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({Key? key}) : super(key: key);
  static const route = '/AppSettings';
  static const String keyTestnetSwitch = 'key-testnet-switch';
  static const String keyOverridePeers = 'key-override-peers';

  @override
  _AppSettingsState createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SettingsScreen(
            title: 'Application Settings',
            children: [
              SwitchSettingsTile(
                settingKey: AppSettings.keyTestnetSwitch,
                title: 'Rex Testnet',
                enabledLabel: 'Enabled',
                disabledLabel: 'Feature temporarily disabled',
                enabled: false,
                //leading: const Icon(Icons.alt_route),
                onChange: (value) {
                  debugPrint('Testnet enabled: $value');
                  Endpoints.testnetEnabled = value;
                },
              ),
              TextInputSettingsTile(
                title: 'Override Peers',
                settingKey: AppSettings.keyOverridePeers,
                initialValue: '',
                autoValidateMode: AutovalidateMode.disabled,
                validator: (String? url) {
                  if (url == null || url.isEmpty) {
                    Endpoints.overridePeers = '';
                    return null;
                  }
                  if (!(Uri.tryParse(url)?.isAbsolute ?? false)) {
                    return 'Invalid url (e.g. http://1.2.3.4:8080)';
                  }
                  Endpoints.overridePeers = url;
                  return null;
                },
              ),
            ],
          ),
        ),
        FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('${snapshot.data!.appName}  v${snapshot.data!.version} ',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ],
                );
              default:
                return const SizedBox(height: 16.0,);
            }
          },
        ),
      ],
    );
  }
}
