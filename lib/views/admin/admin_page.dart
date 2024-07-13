import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restoran_map/cubit/restaurant_cubit.dart';
import 'package:restoran_map/cubit/restaurant_state.dart';
import 'package:restoran_map/models/restaurant.dart';
import 'package:restoran_map/views/users_pages/map_restaurant.dart';
import 'package:restoran_map/views/widgets/add_restaurant.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  void initState() {
    super.initState();
    context.read<RestaurantCubit>().getRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: const Text("Restaurants"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context, builder: (ctx) => const AddRestaurantDialog());
        },
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<RestaurantCubit, RestaurantState>(
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

          return ListView.builder(
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              Restaurant restaurant = restaurants[index];
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.lightBlue,
                ),
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.all(15),
                child: ListTile(
                  title: Text(restaurant.name),
                  subtitle: Text(
                    restaurant.description,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => MapRestaurant(
                          initialLocation: restaurant.location,
                          restaurant: restaurant,
                        ),
                      ),
                    );
                  },
                  trailing: PopupMenuButton(
                    itemBuilder: (ctx) {
                      return [
                        PopupMenuItem(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AddRestaurantDialog(
                                restaurant: restaurant,
                              ),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit,
                                color: Colors.cyan.shade700,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Edit",
                                style: TextStyle(
                                  color: Colors.cyan.shade500,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          onTap: () {
                            context
                                .read<RestaurantCubit>()
                                .deleteRestaurant(restaurant.id);
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.delete,
                                color: Colors.red[900],
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "Delete",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        )
                      ];
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
