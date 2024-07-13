import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_places_autocomplete_text_field/model/prediction.dart';
import 'package:restoran_map/cubit/restaurant_cubit.dart';
import 'package:restoran_map/cubit/restaurant_state.dart';
import 'package:restoran_map/models/restaurant.dart';
import 'package:restoran_map/services/location_service.dart';
import 'package:restoran_map/services/yandex_map_service.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';

class MapRestaurant extends StatefulWidget {
  final Restaurant restaurant;
  final Point? initialLocation;
  MapRestaurant({Key? key, this.initialLocation, required this.restaurant})
      : super(key: key);

  @override
  State<MapRestaurant> createState() => _MapRestaurantState();
}

class _MapRestaurantState extends State<MapRestaurant> {
  late YandexMapController mapController;

  bool isFirstTaped = false;
  Point? tapedPace;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RestaurantCubit>().getRestaurants();
    });
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    await LocationService.getCurrentLcoation();
  }

  void onMapCreated(YandexMapController controller) async {
    mapController = controller;
    if (widget.initialLocation == null) {
      await LocationService.getCurrentLcoation();
      await mapController.toggleUserLayer(visible: true);
      mapController.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: Point(
              latitude: LocationService.currentLocation?.latitude ?? 0.0,
              longitude: LocationService.currentLocation?.longitude ?? 0.0,
            ),
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

  double measure(double lat1, double lon1, double lat2, double lon2) {
    var R = 6378.137; // Radius of earth in KM
    var dLat = lat2 * pi / 180 - lat1 * pi / 180;
    var dLon = lon2 * pi / 180 - lon1 * pi / 180;
    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var d = R * c;
    return d * 1000; // meters
  }

  final _yourGoogleAPIKey = 'AIzaSyBEjfX9jrWudgRcWl2scld4R7s0LtlaQmQ';
  final _textController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  List<MapObject>? polylines;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<RestaurantCubit, RestaurantState>(
            builder: (context, state) {
              if (state is InitialState) {
                return const Center(
                  child: Text("Ma'lumot hali yuklanmadi"),
                );
              }
              if (state is LoadingState) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is ErrorState) {
                return const Center(
                  child: Text("Xatolik sodir bo'ldi!"),
                );
              }

              List<Restaurant> restaurants =
                  (state as LoadedState).restaurantStates;
              return YandexMap(
                onMapCreated: onMapCreated,
                mapObjects: [
                  if (isFirstTaped)
                    PlacemarkMapObject(
                      mapId: const MapObjectId("najotTalim"),
                      point: tapedPace!,
                      icon: PlacemarkIcon.single(
                        PlacemarkIconStyle(
                          image: BitmapDescriptor.fromAssetImage(
                            "assets/route_start.png",
                          ),
                        ),
                      ),
                    ),
                  if (isFirstTaped)
                    PlacemarkMapObject(
                      text: PlacemarkText(
                        text: widget.restaurant.name,
                        style: PlacemarkTextStyle(
                          color: Colors.lightBlue[900],
                          size: 15,
                          placement: TextStylePlacement.top,
                        ),
                      ),
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
                  ...List.generate(
                    restaurants.length,
                    (index) {
                      bool isNear = false;
                      double latitude = restaurants[index].location!.latitude;
                      double longitude = restaurants[index].location!.longitude;

                      double myLatitude =
                          LocationService.currentLocation?.latitude ?? 0.0;
                      double myLongitude =
                          LocationService.currentLocation?.longitude ?? 0.0;

                      double distance =
                          measure(latitude, longitude, myLatitude, myLongitude);

                      if (distance <= 1000 && distance >= 0) {
                        isNear = true;
                      }

                      return widget.restaurant.location !=
                              restaurants[index].location
                          ? PlacemarkMapObject(
                              text: PlacemarkText(
                                text: restaurants[index].name,
                                style: PlacemarkTextStyle(
                                  color: Colors.lightBlue[900],
                                  size: 15,
                                  placement: TextStylePlacement.top,
                                ),
                              ),
                              mapId: MapObjectId(UniqueKey().toString()),
                              point: restaurants[index].location!,
                              icon: PlacemarkIcon.single(
                                PlacemarkIconStyle(
                                  scale: isNear ? 1.5 : 1,
                                  image: BitmapDescriptor.fromAssetImage(
                                    isNear
                                        ? "assets/route_end.png"
                                        : "assets/route_stop_by.png",
                                  ),
                                ),
                              ),
                              onTap: (mapObject, point) async {
                                // isFirstTaped = true;
                                // polylines = await YandexMapService.getDirection(
                                //   Point(
                                //     latitude: LocationService
                                //             .currentLocation?.latitude ??
                                //         0.0,
                                //     longitude: LocationService
                                //             .currentLocation?.longitude ??
                                //         0.0,
                                //   ),
                                //   tapedPace!,
                                // );
                                await showModalBottomSheet(
                                  context: context,
                                  builder: (context) => _ModalBodyView(
                                    restaurant: restaurants[index],
                                  ),
                                );
                              },
                            )
                          : PlacemarkMapObject(
                              mapId: const MapObjectId(""),
                              point: widget.restaurant.location!,
                            );
                    },
                  ),
                ],
              );
            },
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
                      mapController.moveCamera(CameraUpdate.zoomIn());
                    },
                    backgroundColor: Colors.white.withOpacity(0.85),
                    child: const Icon(CupertinoIcons.add, color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    heroTag: "zoom_out",
                    onPressed: () {
                      mapController.moveCamera(CameraUpdate.zoomOut());
                    },
                    backgroundColor: Colors.white.withOpacity(0.85),
                    child:
                        const Icon(CupertinoIcons.minus, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          //     Positioned(
          //       top: 70,
          //       child: Form(
          //         key: _formKey,
          //         autovalidateMode: _autovalidateMode,
          //         child: Padding(
          //           padding:
          //               const EdgeInsets.symmetric(horizontal: 25, vertical: 50),
          //           child: GooglePlacesAutoCompleteTextFormField(
          //             textEditingController: _textController,
          //             googleAPIKey: _yourGoogleAPIKey,
          //             decoration: const InputDecoration(
          //               fillColor: Colors.white,
          //               filled: true,
          //               hintText: 'Enter your address',
          //               border: OutlineInputBorder(
          //                 borderRadius: BorderRadius.all(
          //                   Radius.circular(50),
          //                 ),
          //               ),
          //               prefixIcon: Icon(Icons.search),
          //             ),
          //             validator: (value) {
          //               if (value!.isEmpty) {
          //                 return 'Please enter some text';
          //               }
          //               return null;
          //             },
          //             maxLines: 1,
          //             overlayContainer: (child) => Material(
          //               elevation: 1.0,
          //               color: Colors.white,
          //               borderRadius: BorderRadius.circular(12),
          //               child: child,
          //             ),
          //             getPlaceDetailWithLatLng: (prediction) {
          //               if ((prediction.lat != null) && prediction.lng != null) {
          //                 tapedPace = Point(
          //                   latitude: double.parse(prediction.lat!),
          //                   longitude: double.parse(prediction.lng!),
          //                 );
          //                 setState(() {});
          //                 mapController.moveCamera(
          //                   CameraUpdate.newCameraPosition(
          //                     CameraPosition(target: tapedPace!),
          //                   ),
          //                 );
          //                 isFirstTaped = true;
          //               }
          //             },
          //             itmClick: (Prediction prediction) =>
          //                 _textController.text = prediction.description!,
          //           ),
          //         ),
          //       ),
          //     ),
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
                    latitude: LocationService.currentLocation?.latitude ?? 0.0,
                    longitude:
                        LocationService.currentLocation?.longitude ?? 0.0,
                  ),
                  zoom: 15,
                ),
              ),
            );
          },
          backgroundColor: Colors.white.withOpacity(0.85),
          child: const Icon(CupertinoIcons.location_fill, color: Colors.black),
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
                  style: const TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
