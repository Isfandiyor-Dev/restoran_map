import 'dart:io';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class Restaurant {
  final String name;
  final String description;
  final File? imageUrl;
  final Point? location;

  Restaurant({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.location,
  });
}
