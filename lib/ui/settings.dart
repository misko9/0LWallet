import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:libra/libra_rpc.dart';

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
    return Stack(
      children: [
        Container(
          alignment: Alignment.center,
          child: const Hero(
            tag: 'appsettings',
            child: Icon(
              Icons.settings_outlined,
              color: Colors.grey,
              size: 64,
            ),
          ),
        ),
        SettingsScreen(
          title: 'Application Settings',
          children: [
            SwitchSettingsTile(
              settingKey: AppSettings.keyTestnetSwitch,
              title: 'TestNet (Rex)',
              enabledLabel: 'Enabled',
              disabledLabel: 'Disabled',
              //leading: const Icon(Icons.alt_route),
              onChange: (value) {
                debugPrint('Testnet enabled: $value');
                LibraRpc.testnetEnabled = value;
              },
            ),
            TextInputSettingsTile(
              title: 'Override Peers',
              settingKey: AppSettings.keyOverridePeers,
              initialValue: '',
              autoValidateMode: AutovalidateMode.disabled,
              validator: (String? url) {
                if (url == null || url.isEmpty) {
                  LibraRpc.overridePeers = '';
                  return null;
                }
                if (!(Uri.tryParse(url)?.isAbsolute ?? false)) {
                  return 'Invalid url (e.g. http://1.2.3.4:8080)';
                }
                LibraRpc.overridePeers = url;
                return null;
              },
            ),
          ],
        ),
      ],
    );
  }
}
