import 'package:Oollet/providers/wallet_provider.dart';
import 'package:Oollet/services/rpc_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeDialog extends StatelessWidget {
  const QrCodeDialog({
    Key? key,
    required this.addr,
  }) : super(key: key);
  final String addr;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Scan QR code"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              addr,
              style: const TextStyle(fontSize: 12),
            ),
            Container(
              height: 160,
              width: 160,
              constraints: const BoxConstraints(maxWidth: 160, maxHeight: 160),
              child: QrImage(
                data: addr,
                version: QrVersions.auto,
                errorCorrectionLevel: QrErrorCorrectLevel.H,
                size: 160,
                gapless: true,
                embeddedImage:
                const AssetImage('icons/ol_logo_whitebg_square/1024.png'),
                embeddedImageStyle: QrEmbeddedImageStyle(
                  size: Size(40, 40),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text("OK"),
          onPressed: () {
            Navigator.of(context).pop();
            WalletProvider walletProvider = Provider.of<WalletProvider>(context, listen: false);
            RpcServices.fetchAllAccountInfo(walletProvider, walletProvider.selectedAccount);
          },
        ),
      ],
    );
  }
}
