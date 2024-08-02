import 'package:flutter/foundation.dart'; // Needed for kIsWeb
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:disk_space/disk_space.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  double? _totalSpace;
  double? _freeSpace;

  @override
  void initState() {
    super.initState();
    _initDeviceInfo();
  }

  Future<void> _initDeviceInfo() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    var deviceData = <String, dynamic>{};

    try {
      if (kIsWeb) {
        deviceData = _readWebBrowserInfo(await deviceInfoPlugin.webBrowserInfo);
      }
    } catch (e) {
      deviceData = {'Error:': 'Failed to get device info'};
    }

    try {
      _totalSpace = await DiskSpace.getTotalDiskSpace;
      _freeSpace = await DiskSpace.getFreeDiskSpace;
    } catch (e) {
      // Handle exception if disk space information is not available
    }

    setState(() {
      _deviceData = deviceData;
    });
  }

  Map<String, dynamic> _readWebBrowserInfo(WebBrowserInfo data) {
    return <String, dynamic>{
      'Browser Name': describeEnum(data.browserName),
      'User Agent': data.userAgent,
      'App Code Name': data.appCodeName,
      'App Name': data.appName,
      'App Version': data.appVersion,
      'Language': data.language,
      'Platform': data.platform,
      'Product': data.product,
      'Product Sub': data.productSub,
      'Vendor': data.vendor,
      'Vendor Sub': data.vendorSub,
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Device Info'),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return _buildWideContainers();
            } else {
              return _buildNormalContainers();
            }
          },
        ),
      ),
    );
  }

  Widget _buildWideContainers() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 3,
        children: _buildDeviceInfoWidgets(),
      ),
    );
  }

  Widget _buildNormalContainers() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: _buildDeviceInfoWidgets(),
      ),
    );
  }

  List<Widget> _buildDeviceInfoWidgets() {
    return _deviceData.keys.map((String property) {
      return Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              property,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                '${_deviceData[property]}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      );
    }).toList()
      ..add(Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'Total Disk Space',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                _totalSpace != null
                    ? '${_totalSpace! / (1024 * 1024 * 1024)} GB'
                    : 'Unavailable',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ))
      ..add(Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'Free Disk Space',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                _freeSpace != null
                    ? '${_freeSpace! / (1024 * 1024 * 1024)} GB'
                    : 'Unavailable',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ));
  }
}
