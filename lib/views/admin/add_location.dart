import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:restoran_map/services/location_service.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class AddRestaurantMap extends StatefulWidget {
  const AddRestaurantMap({super.key});

  @override
  State<AddRestaurantMap> createState() => _AddRestaurantMapState();
}

class _AddRestaurantMapState extends State<AddRestaurantMap> {
  late YandexMapController mapController;

  void onMapCreated(YandexMapController controller) async {
    mapController = controller;
    await LocationService.getCurrentLcoation();
    await mapController.toggleUserLayer(visible: true);
    mapController.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(
              latitude: LocationService.currentLocation!.latitude!,
              longitude: LocationService.currentLocation!.longitude!),
          zoom: 12,
        ),
      ),
    );
    setState(() {});
  }

  bool isFirstTaped = false;

  Point? tapedPace;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          YandexMap(
            onMapCreated: onMapCreated,
            onMapTap: (argument) async {
              tapedPace = argument;
              isFirstTaped = true;
              setState(() {});
            },
            mapObjects: [
              if (isFirstTaped)
                PlacemarkMapObject(
                  mapId: const MapObjectId("selected"),
                  point: tapedPace!,
                  icon: PlacemarkIcon.single(
                    PlacemarkIconStyle(
                      image: BitmapDescriptor.fromAssetImage(
                        "assets/route_start.png",
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: 90,
              width: double.infinity,
              child: AppBar(
                title: const Text("Restaurant"),
                centerTitle: true,
                backgroundColor: Colors.grey,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.grey.withOpacity(0.9),
                  fixedSize: const Size(250, 70),
                ),
                onPressed: () {
                  if (isFirstTaped) {
                    Navigator.pop(
                      context,
                      tapedPace,
                    );
                  }
                },
                child: const Text(
                  "Select this place",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(1, 0.1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      mapController.moveCamera(
                        CameraUpdate.zoomIn(),
                      );
                    },
                    backgroundColor: Colors.white.withOpacity(0.85),
                    child: const Icon(
                      CupertinoIcons.add,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    onPressed: () {
                      mapController.moveCamera(
                        CameraUpdate.zoomOut(),
                      );
                    },
                    backgroundColor: Colors.white.withOpacity(0.85),
                    child: const Icon(
                      CupertinoIcons.minus,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: FloatingActionButton(
          onPressed: () async {
            await mapController.toggleUserLayer(visible: true);
            await LocationService.getCurrentLcoation();
            mapController.moveCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: Point(
                      latitude: LocationService.currentLocation!.latitude!,
                      longitude: LocationService.currentLocation!.longitude!),
                  zoom: 15,
                ),
              ),
            );
          },
          backgroundColor: Colors.white.withOpacity(0.85),
          child: const Icon(
            CupertinoIcons.location_fill,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
