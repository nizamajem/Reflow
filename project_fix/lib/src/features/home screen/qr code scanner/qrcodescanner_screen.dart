import 'dart:io';
import 'package:flutter/material.dart';
import 'package:project_fix/src/features/home%20screen/home_screen.dart';
import 'package:project_fix/src/features/home%20screen/qr%20code%20scanner/vehicle%20number/vehiclenumber_screen.dart';
import 'package:project_fix/src/provider/vehicle_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:carousel_slider/carousel_slider.dart';

class QRCodeScannerScreen extends StatefulWidget {
  @override
  _QRCodeScannerScreenState createState() => _QRCodeScannerScreenState();
}

class _QRCodeScannerScreenState extends State<QRCodeScannerScreen>
    with WidgetsBindingObserver {
  String result = "Scan a QR code";
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  final List<String> imgList = [
    'assets/img/bicycle.png',
    'assets/img/bicycle.png',
    'assets/img/bicycle.png',
    // Add more image paths as needed
  ];

  int _currentIndex = 0;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      controller?.pauseCamera();
    } else if (state == AppLifecycleState.resumed) {
      controller?.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void onQRViewCreated(QRViewController qrController) {
    controller = qrController;
    controller?.scannedDataStream.listen((scanData) {
      String vehicleNumber = scanData.code ?? "No data found";
      if (scanData.code != null) {
        controller?.pauseCamera();
        Provider.of<VehicleNumberProvider>(context, listen: false)
            .addLockedVehicle(vehicleNumber);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        ); // Kembalikan hasil scan
      }
      setState(() {
        result = scanData.code ?? "No data found"; // Handle nullable value
      });
    });
  }

  Future<void> toggleFlash() async {
    await controller?.toggleFlash();
    setState(() {});
  }

  Future<void> flipCamera() async {
    await controller?.flipCamera();
    setState(() {});
  }

  Widget buildQrView(double screenWidth, double screenHeight) {
    return QRView(
      key: qrKey,
      onQRViewCreated: onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.white,
        borderRadius: 12,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: screenWidth * 0.7, // 70% of the screen width
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsiveness
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Scan QR code', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: BackButton(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Center(
              child: buildQrView(screenWidth, screenHeight)), // Kotak scanner
          Positioned(
            top: screenHeight * 0.1, // Moved carousel higher up
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  // Carousel for images
                  CarouselSlider(
                    options: CarouselOptions(
                      height: screenHeight * 0.15, // Reduced height of carousel
                      autoPlay: true,
                      enlargeCenterPage: true,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                    ),
                    items: imgList
                        .map((item) => Container(
                              width: screenWidth *
                                  0.5, // Adjust width for responsiveness
                              height: screenHeight *
                                  0.15, // Reduced height for carousel
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  item,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  // Indicators
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: imgList.asMap().entries.map((entry) {
                      return GestureDetector(
                        onTap: () => setState(() {
                          _currentIndex = entry.key;
                        }),
                        child: Container(
                          width: 8.0,
                          height: 8.0,
                          margin: EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (Theme.of(context).primaryColorLight)
                                .withOpacity(
                              _currentIndex == entry.key ? 0.9 : 0.4,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.3, // Adjust for screen size
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Menampilkan hasil scan
                Text(
                  result,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        controller
                            ?.pauseCamera(); // Pause camera before navigation
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VehicleNumberScreen(),
                          ),
                        );
                        // Handle vehicle number display
                      },
                      child: Text(
                        '1234',
                        style: TextStyle(color: Colors.blue),
                      ), // Example vehicle number
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(20),
                      ),
                    ),
                    Text(
                      'Vehicle number',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: toggleFlash,
                      child: Icon(Icons.flashlight_on, color: Colors.blue),
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(20),
                      ),
                    ),
                    Text(
                      'Flashlight',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
