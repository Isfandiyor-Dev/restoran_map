//! InitialState - boshlang'ich holat
//! LoadingState - yuklanish holati
//! LoadedState - yuklanib bo'lgan holati
//! ErrorState - xatolik holati

import 'package:flutter/material.dart';
import 'package:restoran_map/models/restaurant.dart';

@immutable
sealed class RestaurantState {}

final class InitialState extends RestaurantState {}

final class LoadingState extends RestaurantState {}

final class LoadedState extends RestaurantState {
  List<Restaurant> restaurantStates = [];

  LoadedState(this.restaurantStates);
}

final class ErrorState extends RestaurantState {
  String message;

  ErrorState(this.message);
}
