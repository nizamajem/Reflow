import 'package:flutter/material.dart';
import 'package:project_fix/src/features/home%20screen/qr%20code%20scanner/qrcodescanner_screen.dart';
import 'package:project_fix/src/provider/vehicle_provider.dart';
import 'package:provider/provider.dart';

class VehicleUnlockMenu extends StatelessWidget {
  final String vehicleNumber;
  final VoidCallback onClose;
  final VoidCallback onUnlock;
  final VoidCallback onAnother;

  const VehicleUnlockMenu({
    Key? key,
    required this.vehicleNumber,
    required this.onClose,
    required this.onUnlock,
    required this.onAnother,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<VehicleNumberProvider>(
      builder: (context, provider, child) {
        return Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Informasi kendaraan yang dipilih
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vehicleNumber,
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.battery_full,
                                  color: Colors.blue,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "100%",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Image(
                          image: AssetImage("assets/img/bicycle.png"),
                          width: 100,
                          height: 100,
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final vehicleProvider =
                                  Provider.of<VehicleNumberProvider>(context,
                                      listen: false);

                              vehicleProvider
                                  .removeLockedVehicle(vehicleNumber);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        QRCodeScannerScreen()),
                              );
                              onAnother();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              minimumSize: Size(0, 50),
                            ),
                            child: Text(
                              "Another",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              showUnlockDialog(context, vehicleNumber);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              minimumSize: Size(0, 50),
                            ),
                            child: Text(
                              "Unlock Now",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Tombol Close di Pojok Kanan Atas
              Positioned(
                top: -8,
                right: -8,
                child: GestureDetector(
                  onTap: () {
                    final vehicleProvider = Provider.of<VehicleNumberProvider>(
                        context,
                        listen: false);

                    vehicleProvider.removeLockedVehicle(vehicleNumber);
                    onClose();
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.close, color: Colors.black, size: 20),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showUnlockDialog(BuildContext context, String vehicleNumber) {
    final vehicleProvider =
        Provider.of<VehicleNumberProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 3), () {
          vehicleProvider.unlockVehicle(vehicleNumber);
          // onUnlock();
          Navigator.of(context).pop();
        });
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(height: 200),
                  TweenAnimationBuilder(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(seconds: 3),
                    builder: (context, double value, child) {
                      return SizedBox(
                        width: 150,
                        height: 150,
                        child: CircularProgressIndicator(
                          value: value,
                          strokeWidth: 20,
                          color: Colors.blue,
                          backgroundColor: Colors.grey[300],
                        ),
                      );
                    },
                  ),
                  Image.asset(
                    "assets/img/bicycle.png",
                    height: 100,
                  ),
                ],
              ),
              SizedBox(height: 24),
              Text(
                vehicleNumber,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Unlocking",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Timeout in 3 seconds",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}
