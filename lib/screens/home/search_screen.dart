import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_clone/screens/post_screen.dart';
import 'package:instagram_clone/screens/home/profile_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/no_data_found.dart';

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
        leading: isShowUser
            ? IconButton(
                onPressed: () {
                  //* Close the keyboard
                  FocusScope.of(context).unfocus();

                  setState(() {
                    isShowUser = false;
                  });
                },
                icon: const Icon(Icons.arrow_back))
            : null,
        title: SizedBox(
          height: 45,
          child: TextFormField(
            onTap: () {
              setState(() {
                isShowUser = true;
              });
            },
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search',
              hintStyle: TextStyle(
                color: Colors.grey[200],
                fontWeight: FontWeight.normal,
              ),
              fillColor: Colors.grey.shade900,
              filled: true,
              prefixIcon: const Icon(
                Icons.search,
                color: primaryColor,
              ),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          searchController.clear();
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() {
                isShowUser = true;
              });
            },
          ),
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
                if (!snapshot.hasData ||
                    snapshot.hasError ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => ProfileScreen(
                          uid: snapshot.data!.docs[index]['uid'],
                        ),
                      )),
                      leading: CircleAvatar(
                        backgroundColor: imageBgColor,
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
                            onTap: () =>
                                Navigator.of(context).push(MaterialPageRoute(
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
