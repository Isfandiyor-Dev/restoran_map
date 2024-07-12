import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:restoran_map/models/restaurant.dart';
import 'package:restoran_map/services/location_service.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class MapRestaurant extends StatefulWidget {
  Restaurant restaurant;
  Point? initialLocation;
  MapRestaurant({super.key, this.initialLocation, required this.restaurant});

  @override
  State<MapRestaurant> createState() => _MapRestaurantState();
}

class _MapRestaurantState extends State<MapRestaurant> {
  late YandexMapController mapController;

  bool isFirstTaped = false;

  Point? tapedPace;

  void onMapCreated(YandexMapController controller) async {
    mapController = controller;
    if (widget.initialLocation == null) {
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
    } else {
      isFirstTaped = true;
      tapedPace = widget.initialLocation;
      mapController.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: widget.initialLocation!,
            zoom: 18,
          ),
        ),
      );
    }
    setState(() {});
  }

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
                  onTap: (mapObject, point) async {
                    await showModalBottomSheet(
                      context: context,
                      builder: (context) => _ModalBodyView(
                        restaurant: widget.restaurant,
                      ),
                    );
                  },
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
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
          Align(
            alignment: const Alignment(1, -0.5),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: FloatingActionButton(
                heroTag: "shop",
                onPressed: () {},
                backgroundColor: Colors.white.withOpacity(0.85),
                child: const Icon(
                  Icons.shopify_outlined,
                  color: Colors.black,
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
                    heroTag: "zoom_in",
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
                    heroTag: "zoom_out",
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
          heroTag: "user_location",
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

class _ModalBodyView extends StatelessWidget {
  const _ModalBodyView({required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 250,
        padding: const EdgeInsets.all(30),
        child: Row(
          children: [
            restaurant.imageUrl != null
                ? Container(
                    width: 150,
                    height: 180,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.file(
                      restaurant.imageUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                : const SizedBox(),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: 200,
                  height: 100,
                  child: Text(
                    restaurant.description,
                    maxLines: 3,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          ],
        ));
  }
}
