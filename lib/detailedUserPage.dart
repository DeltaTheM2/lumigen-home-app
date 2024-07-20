import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailedUserPage extends StatefulWidget {
  final String userId;

  const DetailedUserPage({Key? key, required this.userId}) : super(key: key);

  @override
  _DetailedUserPageState createState() => _DetailedUserPageState();
}

class _DetailedUserPageState extends State<DetailedUserPage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      setState(() {
        userData = userDoc.data() as Map<String, dynamic>?;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Info'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : userData == null
          ? Center(child: Text('No user data available'))
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Full name",
              style: TextStyle(fontSize: 24),
            ),
            Container(
              padding: EdgeInsets.all(8),
              width: double.infinity,
              height: 100,
              child: Card(
                  elevation: 1,
                  child: Center(
                      child: Text(
                        "${userData!['firstName'].toString() + " " + userData!['lastName'].toString()}",
                        style: TextStyle(fontSize: 18),
                      ))),
            ),
            Text(
              "Email",
              style: TextStyle(fontSize: 24),
            ),
            Container(
              padding: EdgeInsets.all(8),
              width: double.infinity,
              height: 100,
              child: Card(
                  elevation: 1,
                  child: Center(
                      child: Text(
                        "${userData!['email'].toString()}",
                        style: TextStyle(fontSize: 18),
                      ))),
            ),
            SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }
}
