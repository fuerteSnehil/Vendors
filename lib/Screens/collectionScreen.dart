import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:vendors/Utils/constants.dart';

class TodayCollectionScreen extends StatefulWidget {
  @override
  _TodayCheckedInSumScreenState createState() =>
      _TodayCheckedInSumScreenState();
}

class _TodayCheckedInSumScreenState extends State<TodayCollectionScreen>
    with SingleTickerProviderStateMixin {
  late double totalAmount;
  late AnimationController _animationController;
  late Animation<double> _animation;
  late bool isLoading;

  @override
  void initState() {
    super.initState();
    totalAmount = 0;
    isLoading = true; // Set initial loading state

    // Initialize animation controller and animation
    _animationController = AnimationController(
      duration: Duration(seconds: 2), // Adjust the duration as needed
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: totalAmount).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Trigger the animation when the widget is built
    _animationController.forward();

    _fetchTodayCheckedInSum();
  }

  Future<void> _fetchTodayCheckedInSum() async {
    final now = DateTime.now().toString();

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('PunchedOutVehicles')
          .where('checkoutTime', isGreaterThanOrEqualTo: now)
          .get();

      final List<DocumentSnapshot> documents = querySnapshot.docs;
      double sum = 0;

      for (final doc in documents) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        sum += double.parse(
            data['amount']); // Assuming 'amount' is a numeric field
      }

      setState(() {
        totalAmount = sum;
        isLoading = false; // Set loading state to false

        // Update the animation end value
        _animation = Tween<double>(begin: 0, end: totalAmount).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

        // Reset the animation
        _animationController.reset();
        _animationController.forward();
      });
    } catch (error) {
      print('Error fetching data: $error');
      isLoading = false; // Set loading state to false in case of an error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: amber,
        title: Text('Today\'s Collection'),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: amber,
                backgroundColor: black,
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/card.gif',
                    scale: 1,
                  ),
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Text(
                        'Today\'s Collection',
                        style: TextStyle(fontSize: 18),
                      );
                    },
                  ),
                  SizedBox(height: 10),
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Text(
                        '₹${_animation.value.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
