import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyProductsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background color
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "My Products",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .where('isApproved', whereIn: ['Approved', 'Pending', 'Rejected'])
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data!.docs;

          if (products.isEmpty) {
            return Center(
              child: Text(
                "You have no products.",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
            );
          }

          final Map<String, Map<String, List<DocumentSnapshot>>> productsByCategory = {};

          for (final product in products) {
            final category = product['category'];
            final productName = product['productName'];

            if (!productsByCategory.containsKey(category)) {
              productsByCategory[category] = {};
            }

            if (!productsByCategory[category]!.containsKey(productName)) {
              productsByCategory[category]![productName] = [];
            }

            productsByCategory[category]![productName]!.add(product);
          }

          return ListView.builder(
            itemCount: productsByCategory.length,
            itemBuilder: (context, index) {
              final category = productsByCategory.keys.elementAt(index);
              final categoryMap = productsByCategory[category]!;

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: ExpansionTile(
                  title: Text(
                    'Category: $category',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue, // Updated category color
                    ),
                  ),
                  children: categoryMap.keys.map((productName) {
                    final productItems = categoryMap[productName]!;

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: ExpansionTile(
                        title: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(productItems[0]['productImage'] ?? ''),
                              radius: 30,
                            ),
                            SizedBox(width: 16),
                            Text(
                              'Product Name: $productName',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        children: productItems.map((product) {
                          final productDescription = product['productDescription'];
                          final productPrice = product['productPrice'];
                          final stock = product['stock'];

                          String status = 'Pending Approval';
                          if (product['isApproved'] == 'Approved') {
                            status = 'Approved';
                          } else if (product['isApproved'] == 'Rejected') {
                            status = 'Rejected';
                          }

                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16), // Increased padding
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Product Price: ₹$productPrice.00", // Include the Rupee sign (₹) before the price
                                    style: TextStyle(
                                      fontSize: 20, // Larger font size
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold, // You can also add fontWeight for emphasis
                                    ),
                                  ),
                                  Text(
                                    "Product Description: $productDescription",
                                    style: TextStyle(
                                      fontSize: 20, // Larger font size
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    "Stock: $stock KG",
                                    style: TextStyle(
                                      fontSize: 20, // Larger font size
                                      color: Colors.red,
                                    ),
                                  ),
                                  GestureDetector(
                                    child: Text(
                                      "Check Status",
                                      style: TextStyle(
                                        color: status == 'Approved' ? Colors.green : status == 'Rejected' ? Colors.red : Colors.blue,
                                        fontSize: 20, // Larger font size
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text("Status Remark"),
                                            content: Text(
                                              "Status: $status",
                                              style: TextStyle(
                                                color: status == 'Approved' ? Colors.green : status == 'Rejected' ? Colors.red : Colors.blue,
                                                fontSize: 18, // Larger font size
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text("Close"),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
