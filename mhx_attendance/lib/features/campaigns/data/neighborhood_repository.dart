import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/neighborhood.dart';

class NeighborhoodRepository {
  NeighborhoodRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _neighborhoods =>
      _firestore.collection('neighborhoods');

  Stream<List<Neighborhood>> watchNeighborhoods() {
    return _neighborhoods.orderBy('name').snapshots().map(
          (snap) => snap.docs.map(Neighborhood.fromFirestore).toList(),
        );
  }
}
