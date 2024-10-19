import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_clone/resources/firestore_method.dart';
import 'package:instagram_clone/screens/home/profile_screen.dart';
import 'package:instagram_clone/screens/post_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/no_data_found.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late List<DocumentSnapshot> _allUser;
  late List<DocumentSnapshot> _filteredUser;

  @override
  void initState() {
    super.initState();
    _allUser = [];
    _filteredUser = [];
    fetchingUser();
  }

  void fetchingUser() async {
    final snap = await FirestoreMethod.fetchUsers();

    setState(() {
      _allUser = snap;
      _filteredUser = snap;
    });
  }

  List<Widget> _buildSearchResult(String query) {
    _filteredUser = _allUser.where(
      (user) {
        String fullName = user['username'].toLowerCase();
        return fullName.contains(query);
      },
    ).toList();

    return _filteredUser.map(
      (user) {
        return ListTile(
          title: Text(user['username']),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => ProfileScreen(
              uid: user['uid'],
            ),
          )),
          leading: CircleAvatar(
            backgroundColor: imageBgColor,
            backgroundImage: NetworkImage(
              user['photoUrl'],
            ),
          ),
        );
      },
    ).toList();
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
            return _buildSearchResult(controller.text.toLowerCase());
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
