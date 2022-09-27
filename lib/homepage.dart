import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class MyGoogleMap extends StatefulWidget {
  const MyGoogleMap({Key? key}) : super(key: key);

  @override
  State<MyGoogleMap> createState() => _MyGoogleMapState();
}

class _MyGoogleMapState extends State<MyGoogleMap> {
  @override
  double lat = 0;
  double long = 0;

  Completer<GoogleMapController> googleMapController = Completer();

  late CameraPosition position;

  MapType _currentMapType = MapType.hybrid;

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  liveLocation() async {}
  checkPermission() async {
    await Permission.location.request();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkPermission();
    position = CameraPosition(
      target: LatLng(lat, long),
      zoom: 10,
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google Map"),
        backgroundColor: Colors.blueAccent[700],
        actions: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Live Codinates"),
              Text("$lat,$long"),
            ],
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              googleMapController.complete(controller);
            },
            initialCameraPosition: position,
            mapType: _currentMapType,
            mapToolbarEnabled: true,
            markers: <Marker>{
              Marker(
                markerId: const MarkerId("Current Location"),
                position: LatLng(lat, long),
              ),
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topRight,
              child: Column(
                children: <Widget>[
                  FloatingActionButton(
                    onPressed: _onMapTypeButtonPressed,
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor: Colors.blueAccent,
                    child: const Icon(Icons.map, size: 36.0),
                  ),
                  const SizedBox(height: 16.0),
                  FloatingActionButton(
                    onPressed: () async {
                      Geolocator.getPositionStream()
                          .listen((Position position) async {
                        setState(() {
                          lat = position.latitude;
                          long = position.longitude;
                        });
                      });
                      setState(() {
                        position = CameraPosition(
                          zoom: 10,
                          target: LatLng(lat, long),
                        );
                      });
                      final GoogleMapController controller =
                          await googleMapController.future;
                      controller.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            zoom: 80,
                            target: LatLng(lat, long),
                          ),
                        ),
                      );
                    },
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor: Colors.blueAccent,
                    child: const Icon(Icons.my_location_outlined, size: 36.0),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
