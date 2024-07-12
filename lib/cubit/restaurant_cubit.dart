import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'package:bloc/bloc.dart';
import 'package:restoran_map/cubit/restaurant_state.dart';
import 'package:restoran_map/models/restaurant.dart';

class RestaurantCubit extends Cubit<RestaurantState> {
  RestaurantCubit() : super(InitialState());

  final List<Restaurant> _restaurants = [
    Restaurant(
      name: 'Afsona',
      description: 'A traditional Uzbek restaurant with a cozy atmosphere.',
      imageUrl: null,
      location: const Point(latitude: 41.2995, longitude: 69.2401),
    ),
    Restaurant(
      name: 'Plov Center',
      description: 'Famous for its delicious plov and other Uzbek dishes.',
      imageUrl: null,
      location: const Point(latitude: 41.3111,longitude: 69.2796),
    ),
    Restaurant(
      name: 'Caravan',
      description:
          'Offers a mix of traditional and contemporary Uzbek cuisine.',
      imageUrl: null,
      location: const Point(latitude: 41.3123,longitude: 69.2785),
    ),
    Restaurant(
      name: 'Bibigon',
      description: 'A popular spot for Korean cuisine in Tashkent.',
      imageUrl: null,
      location: const Point(latitude: 41.2992,longitude: 69.2414),
    ),
    Restaurant(
      name: 'Navat',
      description:
          'A modern restaurant serving a variety of international dishes.',
      imageUrl: null,
      location: const Point(latitude: 41.3119,longitude: 69.2797),
    ),
    Restaurant(
      name: 'Sato',
      description:
          'Known for its elegant ambiance and delicious Japanese food.',
      imageUrl: null,
      location: const Point(latitude: 41.2958,longitude: 69.2409),
    ),
    Restaurant(
      name: 'Basilic',
      description: 'A chic restaurant with a focus on Mediterranean cuisine.',
      imageUrl: null,
      location: const Point(latitude: 41.3116,longitude: 69.2758),
    ),
    Restaurant(
      name: 'La Piola',
      description:
          'A cozy Italian restaurant with a wide selection of pizzas and pastas.',
      imageUrl: null,
      location: const Point(latitude: 41.3105,longitude: 69.2789),
    ),
    Restaurant(
      name: 'Dolce Vita',
      description: 'Serves Italian cuisine with a focus on fresh ingredients.',
      imageUrl: null,
      location: const Point(latitude: 41.3031,longitude: 69.2651),
    ),
    Restaurant(
      name: 'Samarkand',
      description:
          'Offers a variety of traditional Uzbek dishes in a beautiful setting.',
      imageUrl: null,
      location: const Point(latitude: 41.2929,longitude: 69.2646),
    ),
    Restaurant(
      name: 'Lepeshka',
      description:
          'A bakery and cafe known for its delicious pastries and bread.',
      imageUrl: null,
      location: const Point(latitude: 41.2982,longitude: 69.2726),
    ),
    Restaurant(
      name: 'The Irish Pub',
      description: 'A popular spot for a pint of beer and classic pub food.',
      imageUrl: null,
      location: const Point(latitude: 41.3045,longitude: 69.2811),
    ),
    Restaurant(
      name: 'Chelsea',
      description:
          'A British-themed pub with a variety of international dishes.',
      imageUrl: null,
      location: const Point(latitude: 41.3053,longitude: 69.2804),
    ),
    Restaurant(
      name: 'Stuzzico',
      description:
          'An Italian restaurant known for its authentic dishes and cozy atmosphere.',
      imageUrl: null,
      location: const Point(latitude: 41.3064,longitude: 69.2821),
    ),
    Restaurant(
      name: 'Beerhouse',
      description:
          'A lively bar with a great selection of beers and bar snacks.',
      imageUrl: null,
      location: const Point(latitude: 41.3072,longitude: 69.2800),
    ),
    Restaurant(
      name: 'Shishka',
      description: 'A trendy restaurant and bar with a vibrant atmosphere.',
      imageUrl: null,
      location: const Point(latitude: 41.3081,longitude: 69.2794),
    ),
    Restaurant(
      name: 'Berserk',
      description:
          'A themed restaurant offering a variety of international dishes.',
      imageUrl: null,
      location: const Point(latitude: 41.3092,longitude: 69.2788),
    ),
    Restaurant(
      name: 'Aura',
      description:
          'A modern restaurant with a focus on healthy and organic food.',
      imageUrl: null,
      location: const Point(latitude: 41.3100,longitude: 69.2773),
    ),
    Restaurant(
      name: 'Ariston',
      description: 'A fine dining restaurant with an extensive wine list.',
      imageUrl: null,
      location: const Point(latitude: 41.3113,longitude: 69.2761),
    ),
    Restaurant(
      name: 'Brahma',
      description:
          'An Indian restaurant known for its authentic curries and spices.',
      imageUrl: null,
      location: const Point(latitude: 41.3125,longitude: 69.2754),
    ),
  ];

  Future<void> addRestaurant(Restaurant restaurant) async {
    try {
      emit(LoadingState());
      _restaurants.add(restaurant);
      emit(LoadedState(_restaurants));
    } catch (e) {
      print("Qo'shishda xatolik yuz berdi $e");
      emit(ErrorState("Error: Xatorlik $e"));
    }
  }

  Future<void> getRestaurants() async {
    try {
      emit(LoadingState());
      await Future.delayed(const Duration(seconds: 2));
      emit(LoadedState(_restaurants));
    } catch (e) {
      print("Xatolik sodir bo'ldi");
      emit(ErrorState("Rejalarni ololmadim"));
    }
  }
}
