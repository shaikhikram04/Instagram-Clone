import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_clone/resources/firestore_method.dart';
import 'package:instagram_clone/screens/post_screen.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/no_data_found.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late List<DocumentSnapshot> _allUser;

  @override
  void initState() {
    super.initState();
    _allUser = [];
    fetchingUser();
  }

  void fetchingUser() async {
    final snap = await FirestoreMethod.fetchUsers();

    setState(() {
      _allUser = snap;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SearchAnchor.bar(
          barHintText: 'Search',
          barHintStyle: const WidgetStatePropertyAll(
            TextStyle(color: Color.fromARGB(255, 218, 218, 218)),
          ),
          constraints: const BoxConstraints(minHeight: 45),
          suggestionsBuilder: (context, controller) {
            return buildSearchResult(
              query: controller.text.toLowerCase(),
              allUser: _allUser,
              context: context,
              goTo: 'ProfileScreen',
            );
          },
        ),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection('posts').get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const NoDataFound(title: 'posts');
          }
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.hasError) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: StaggeredGrid.count(
              axisDirection: AxisDirection.down,
              crossAxisCount: 3,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              children: [
                for (var index = 0; index < snapshot.data!.size; index++)
                  StaggeredGridTile.count(
                    crossAxisCellCount: (index % 7 == 0) ? 2 : 1,
                    mainAxisCellCount: (index % 7 == 0) ? 2 : 1,
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => PostScreen(
                          snap: snapshot.data!.docs[index].data(),
                        ),
                      )),
                      child: Image.network(
                        snapshot.data!.docs[index]['postUrl'],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
