import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/models/user_model.dart' as model;
import 'package:instagram_flutter/providers/user_provider.dart';
import 'package:instagram_flutter/resources/firestore_methods.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/widgets/comment_card.dart';
import 'package:provider/provider.dart';

class CommentScreen extends StatefulWidget {
  final snap;
  const CommentScreen({super.key, required this.snap});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  @override
  Widget build(BuildContext context) {
    final model.User? user = Provider.of<UserProvider>(context).getUser;

    final TextEditingController _commentController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text('Comments'),
      ),
      bottomNavigationBar: Container(
        height: kToolbarHeight,
        margin: EdgeInsets.only(
          left: 10,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage:
                  user != null ? NetworkImage(user.photoUrl) : NetworkImage(''),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: user != null ? 'Comment as ${user.username}' : '',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                await FirestoreMethods().postComment(
                  postId: widget.snap['postId'].toString(),
                  text: _commentController.text,
                  uid: user != null ? user.uid : '',
                  name: user != null ? user.username : '',
                  profilePic: user != null ? user.photoUrl : '',
                );
                setState(() {
                  _commentController.text = '';
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Text('Post', style: TextStyle(color: Colors.blueAccent)),
              ),
            ),
          ],
        ),
      ),

      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance
                .collection('posts')
                .doc(widget.snap['postId'])
                .collection('comments')
                .orderBy('datePublished', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return (Center(child: CircularProgressIndicator()));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                return CommentCard(snap: snapshot.data!.docs[index].data());
              },
            );
          }
        },
      ),
    );
  }
}
  