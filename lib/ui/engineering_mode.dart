import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:libra/endpoints.dart';
import 'package:libra/models/endpoint.dart';

class EngineeringMode extends StatefulWidget {
  static const route = '/EngineeringMode';

  const EngineeringMode({Key? key}) : super(key: key);

  @override
  _EngineeringModeState createState() => _EngineeringModeState();
}

class _EngineeringModeState extends State<EngineeringMode> {
  bool _refreshEnabled = true;

  @override
  Widget build(BuildContext context) {
    List<Endpoint> endpointList = Endpoints.currentEndpointList;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Engineering Mode'),
      ),
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text("Good nodes: ${Endpoints.goodNodes.length}"),
                Text("RMS Version: ${Endpoints.rmsVersion}"),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text("IP/URL", style: TextStyle(decoration: TextDecoration.underline),)),
                      Expanded(flex: 2, child: Text("Version", style: TextStyle(decoration: TextDecoration.underline),)),
                      Expanded(flex: 1, child: Text("Avail?", style: TextStyle(decoration: TextDecoration.underline),)),
                      Expanded(flex: 1, child: Text("Status", style: TextStyle(decoration: TextDecoration.underline),)),
                    ],
                  ),
                ),
                ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: endpointList.length,
                  itemBuilder: (context, index) {
                    Endpoint endpoint = endpointList[index];
                    bool goodNode = endpoint.is_avail && (endpoint.version >= Endpoints.rmsVersion);
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(flex: 3, child: Text(endpoint.url)),
                            Expanded(
                                flex: 2, child: Text("${endpoint.version}")),
                            Expanded(
                                flex: 1, child: Text("${endpoint.is_avail}")),
                            Expanded(flex: 1, child: Icon(Icons.circle, color: goodNode ? Colors.green : Colors.red, size: 12,)),
                          ],
                        ),
                        index+1 < endpointList.length ? Divider(height: 4, thickness: 2,) : Container(),
                      ],
                    );
                  },
                ),
                SizedBox(height: 10),
                ElevatedButton(
                    onPressed: _refreshEnabled ? () {
                      setState(() => _refreshEnabled = false);
                      Endpoints.updateEndpoints().then((_) {
                        setState(() {});
                        Timer(Duration(seconds: 10), () => setState(() => _refreshEnabled = true));
                      });
                    } : null,
                    child: Text("Refresh")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
