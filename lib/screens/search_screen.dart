import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_clone/utils/colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final searchController = TextEditingController();

  bool isShowUser = false;

  @override
  void dispose() {
    super.dispose();
    searchController.dispose;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: TextFormField(
          controller: searchController,
          decoration: const InputDecoration(
            labelText: 'Search for a user',
            border: InputBorder.none,
          ),
          onFieldSubmitted: (value) {
            setState(() {
              isShowUser = true;
            });
          },
        ),
      ),
      body: isShowUser
          ? FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .where(
                    'username',
                    isGreaterThanOrEqualTo: searchController.text,
                  )
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey,
                        backgroundImage: NetworkImage(
                          snapshot.data!.docs[index]['photoUrl'],
                        ),
                      ),
                      title: Text(snapshot.data!.docs[index]['username']),
                    );
                  },
                );
              },
            )
          : FutureBuilder(
              future: FirebaseFirestore.instance.collection('posts').get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: Text('No Post'));
                }
                if (snapshot.connectionState == ConnectionState.waiting ||
                    snapshot.hasError) {
                  return const Center(child: CircularProgressIndicator());
                }

                return StaggeredGrid.count(
                  axisDirection: AxisDirection.down,
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: [
                    for (var index = 0; index < snapshot.data!.size; index++)
                      StaggeredGridTile.count(
                        crossAxisCellCount: (index % 7 == 0) ? 2 : 1,
                        mainAxisCellCount: (index % 7 == 0) ? 2 : 1,
                        child: Image.network(
                          snapshot.data!.docs[index]['postUrl'],
                          fit: BoxFit.cover,
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }
}
