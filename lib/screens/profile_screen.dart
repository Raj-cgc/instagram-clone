import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/resources/auth_methods.dart';
import 'package:instagram_flutter/resources/firestore_methods.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/utils/utils.dart';
import 'package:instagram_flutter/widgets/follow_button.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({super.key, required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  int postLength = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.uid)
              .get();

      //get post length
      var postSnap =
          await FirebaseFirestore.instance
              .collection('posts')
              .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .get();
      postLength = postSnap.docs.length;
      userData = userSnap.data()!;
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'].length;

      if (userData['followers'].contains(
        FirebaseAuth.instance.currentUser!.uid,
      )) {
        isFollowing = true;
      } else {
        isFollowing = false;
      }

      setState(() {});
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
          appBar: AppBar(
            backgroundColor: mobileBackgroundColor,
            title: Text(userData['username']),
          ),
          body: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(userData['photoUrl']),
                          radius: 40,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  buildStateColumn(postLength, 'posts'),
                                  buildStateColumn(followers, 'followers'),
                                  buildStateColumn(following, 'following'),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  widget.uid ==
                                          FirebaseAuth.instance.currentUser!.uid
                                      ? FollowButton(
                                        backgroundColor: mobileBackgroundColor,
                                        borderColor: Colors.grey,
                                        text: 'Sign Out',
                                        textColor: primaryColor,
                                        function: () async {
                                          await AuthMethods().signOut();
                                        },
                                      )
                                      : isFollowing == true
                                      ? FollowButton(
                                        backgroundColor: Colors.white,
                                        borderColor: Colors.grey,
                                        text: 'Unfollow',
                                        textColor: Colors.black,
                                        function: () async {
                                          await FirestoreMethods().followUser(
                                            uid:
                                                FirebaseAuth
                                                    .instance
                                                    .currentUser!
                                                    .uid,
                                            followId: userData['uid'],
                                          );
                                          setState(() {
                                            isFollowing = false;
                                            followers--;
                                          });
                                        },
                                      )
                                      : FollowButton(
                                        backgroundColor: Colors.blue,
                                        borderColor: Colors.blue,
                                        text: 'Follow',
                                        textColor: primaryColor,
                                        function: () async {
                                          await FirestoreMethods().followUser(
                                            uid:
                                                FirebaseAuth
                                                    .instance
                                                    .currentUser!
                                                    .uid,
                                            followId: userData['uid'],
                                          );
                                          setState(() {
                                            isFollowing = true;
                                            followers++;
                                          });
                                        },
                                      ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(top: 15),
                      child: Text(
                        userData['username'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(top: 1),
                      child: Text(userData['bio']),
                    ),
                  ],
                ),
              ),
              Divider(),
              FutureBuilder(
                future:
                    FirebaseFirestore.instance
                        .collection('posts')
                        .where('uid', isEqualTo: widget.uid)
                        .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return GridView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 1.5,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        DocumentSnapshot snap = snapshot.data!.docs[index];
                        return Container(
                          child: Image(
                            image: NetworkImage(snap['postUrl']),
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        );
  }

  Column buildStateColumn(int num, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          num.toString(),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
