import 'package:flutter/material.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/blue_button.dart';

class ShareScreen extends StatefulWidget {
  const ShareScreen({super.key});

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  List<String> items = List.generate(20, (index) => 'Item $index');
  Set<int> selectedItems = {};
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
        ),
        DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.5,
          maxChildSize: 1.0,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 18),
                    child: SearchAnchor(
                        builder: (context, controller) => SearchBar(
                              hintText: 'Search',
                              backgroundColor:
                                  WidgetStatePropertyAll(Colors.grey[830]),
                              leading: const Icon(Icons.search),
                              shape: const WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10)))),
                            ),
                        suggestionsBuilder: (context, controller) {
                          return [
                            
                          ];
                        }),
                  ),
                  Expanded(
                    child: GridView.builder(
                      controller: scrollController, // Attach scrollController
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        bool isSelected = selectedItems.contains(index);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                selectedItems.remove(index);
                              } else {
                                selectedItems.add(index);
                              }
                            });
                          },
                          child: Stack(
                            children: [
                              const Positioned(
                                top: 10,
                                left: 20,
                                right: 20,
                                child: CircleAvatar(
                                  radius: 45,
                                  backgroundImage: NetworkImage(
                                    'https://plus.unsplash.com/premium_photo-1695868739139-167c2213f00f?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxmZWF0dXJlZC1waG90b3MtZmVlZHwyNHx8fGVufDB8fHx8fA%3D%3D',
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Positioned(
                                  left: 95,
                                  top: 70,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.grey[900],
                                    radius: 15,
                                    child: const Padding(
                                      padding: EdgeInsets.all(0.5),
                                      child: Icon(
                                        Icons.check_circle_rounded,
                                        color: blueColor,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ),
                              const Positioned(
                                top: 110,
                                left: 20,
                                right: 20,
                                child: Text(
                                  'cnewnc ewoewbciewu',
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Divider(
                    height: 2,
                    thickness: 1,
                    color: Colors.grey[700],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: TextField(
                      style: TextStyle(fontSize: 18.5),
                      decoration: InputDecoration(
                        hintText: 'Write a message...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: BlueButton(
                      onTap: () {},
                      label: 'Send',
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
