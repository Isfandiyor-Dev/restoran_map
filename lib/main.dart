import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restoran_map/cubit/restaurant_cubit.dart';
import 'package:restoran_map/services/location_service.dart';
import 'package:restoran_map/views/admin/admin_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocationService.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RestaurantCubit(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AdminPage(),
      ),
    );
  }
}
