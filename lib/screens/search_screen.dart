import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_flutter/screens/profile_screen.dart';
import 'package:instagram_flutter/utils/colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: TextFormField(
          controller: searchController,
          decoration: InputDecoration(labelText: 'Search for a user'),
          onFieldSubmitted: (String s) {
            setState(() {
              isShowUsers = true;
            });
            ;
          },
        ),
      ),
      body:
          isShowUsers == true
              ? FutureBuilder(
                future:
                    FirebaseFirestore.instance
                        .collection('users')
                        .where(
                          'username',
                          isGreaterThanOrEqualTo: searchController.text,
                        )
                        .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap:
                              () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (context) => ProfileScreen(
                                        uid: snapshot.data!.docs[index]['uid'],
                                      ),
                                ),
                              ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                snapshot.data!.docs[index]['photoUrl'],
                              ),
                            ),
                            title: Text(snapshot.data!.docs[index]['username']),
                          ),
                        );
                      },
                    );
                  }
                },
              )
              : FutureBuilder(
                future: FirebaseFirestore.instance.collection('posts').get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return MasonryGridView.count(
                      crossAxisCount: 3,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          snapshot.data!.docs[index]['postUrl'],
                        );
                      },
                    );
                  }
                },
              ),
    );
  }
}
