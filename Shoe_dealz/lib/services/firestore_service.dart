import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart'; 

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  
  Stream<List<Product>> getProducts(String selectedCategory) {
    Query query = _db.collection('products'); 

    if (selectedCategory != 'All') {
      query = query.where('category', isEqualTo: selectedCategory);
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

 
  Future<void> addToCartFirebase(Product product, int size, int quantity) async {
    final user = _auth.currentUser;
    if (user == null) return; 

    final cartRef = _db.collection('users').doc(user.uid).collection('cart');

    final query = await cartRef
        .where('productId', isEqualTo: product.id)
        .where('size', isEqualTo: size)
        .get();

    if (query.docs.isNotEmpty) {
      final docId = query.docs.first.id;
      final currentQuantity = query.docs.first['quantity'];
      await cartRef.doc(docId).update({'quantity': currentQuantity + quantity});
    } else {
      await cartRef.add({
        'productId': product.id,
        'name': product.name,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'size': size,
        'quantity': quantity,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> removeFromCartFirebase(String productId, int size) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final cartRef = _db.collection('users').doc(user.uid).collection('cart');

    final query = await cartRef
        .where('productId', isEqualTo: productId)
        .where('size', isEqualTo: size)
        .get();

    for (var doc in query.docs) {
      await doc.reference.delete();
    }
  }

 
  Future<void> clearCartFirebase() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final cartRef = _db.collection('users').doc(user.uid).collection('cart');

    final snapshots = await cartRef.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }

 
  Future<bool> placeOrder(String shippingAddress, double totalAmount) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final userRef = _db.collection('users').doc(user.uid);
      final cartRef = userRef.collection('cart');
      final ordersRef = userRef.collection('orders').doc();

      
      final cartSnapshot = await cartRef.get();
      if (cartSnapshot.docs.isEmpty) return false;

      final itemsList = cartSnapshot.docs.map((doc) => doc.data()).toList();

      
      await ordersRef.set({
        'orderId': ordersRef.id,
        'items': itemsList,
        'totalAmount': totalAmount,
        'shippingAddress': shippingAddress,
        'status': 'Processing', 
        'orderDate': FieldValue.serverTimestamp(),
      });

     
      for (var doc in cartSnapshot.docs) {
        await doc.reference.delete();
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<QuerySnapshot> getUserOrders() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('orders')
        .orderBy('orderDate', descending: true)
        .snapshots();
  }

  
  Future<bool> hasPreviousOrders() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final snapshot = await _db
        .collection('users')
        .doc(user.uid)
        .collection('orders')
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty; 
  }

  Future<void> toggleFavorite(Product product) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _db.collection('users').doc(user.uid).collection('favorites').doc(product.id);
    
    final doc = await docRef.get();
    if (doc.exists) {
      
      await docRef.delete();
    } else {
      
      await docRef.set({
        'id': product.id,
        'name': product.name,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'category': product.category,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Favorite කරපු සපත්තු ටික ගන්න එක (Favorites Screen එකට)
  Stream<List<Product>> getFavorites() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }
  
  // =========================================================
  // Product-Specific Chat Functions
  // =========================================================

  Future<void> sendProductMessage(Product product, String text) async {
    final user = _auth.currentUser;
    if (user == null) return;

    
    final chatRoomRef = _db.collection('users').doc(user.uid).collection('chats').doc(product.id);

    
    await chatRoomRef.set({
      'productId': product.id,
      'productName': product.name,
      'productImage': product.imageUrl,
      'lastMessage': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    
    await chatRoomRef.collection('messages').add({
      'text': text,
      'senderId': user.uid,
      'isMe': true, 
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  
  Stream<QuerySnapshot> getProductChatMessages(String productId) {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('chats')
        .doc(productId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

 
  Stream<QuerySnapshot> getChatRooms() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('chats')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}