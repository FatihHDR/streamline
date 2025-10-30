import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stock_item.dart';
import '../models/stock_transaction.dart';

class ApiService {
  static const String baseUrl = 'https://dummyjson.com/products';

  Future<List<StockItem>> getStockItems() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = data['products'] as List;

        return products
            .map(
              (product) => StockItem(
                id: product['id'].toString(),
                name: product['title'],
                description: product['description'],
                category: product['category'],
                quantity: product['stock'] ?? 0,
                unit: 'pcs',
                lastUpdated:
                    DateTime.tryParse(product['meta']?['updatedAt'] ?? '') ??
                    DateTime.now(),
                location: product['brand'] ?? 'Unknown',
                minStock: product['minimumOrderQuantity'] ?? 10,
              ),
            )
            .toList();
      } else {
        throw Exception('Failed to load stock items');
      }
    } catch (e) {
      throw Exception('Error fetching stock items: $e');
    }
  }

  Future<List<StockTransaction>> getTransactions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/1/reviews'),
      ); // Using reviews as sample transactions

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final reviews = data['reviews'] as List;

        return reviews
            .map(
              (review) => StockTransaction(
                id: review['id'].toString(),
                itemId: '1',
                itemName:
                    'Sample Item', // We would normally fetch this from the item details
                type: review['rating'] > 3
                    ? TransactionType.incoming
                    : TransactionType.outgoing,
                quantity: (review['rating'] * 2).round(),
                date: DateTime.parse(review['date']),
                note: review['comment'],
                performedBy: review['reviewerName'],
              ),
            )
            .toList();
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch (e) {
      throw Exception('Error fetching transactions: $e');
    }
  }
}
