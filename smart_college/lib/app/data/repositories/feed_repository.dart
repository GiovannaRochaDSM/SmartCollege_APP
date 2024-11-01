import 'dart:convert';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/data/models/feed_model.dart';
import 'package:smart_college/app/common/constants/app_routes.dart';

abstract class IFeedRepository {
  Future<List<FeedModel>> getPublications(String? universityId, String? token);
  Future<FeedModel> getPublicationById(String publicationId, String? token);
  Future<bool> updatePublication(FeedModel publication, String? token);
  Future<bool> addPublication(FeedModel publication, String? token);
  Future<bool> deletePublication(String publicationId, String? token);
}

class FeedRepository implements IFeedRepository {
  final IHttpClient client;

  FeedRepository({required this.client});

  @override
  Future<List<FeedModel>> getPublications(String? universityId, String? token) async {
    final response = await client.get(
      url: AppRoutes.feed,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<FeedModel> publications = [];
      final List<dynamic> body = jsonDecode(response.body);

      for (var item in body) {
        if (item is Map<String, dynamic> && item.containsKey('title')) {
          final FeedModel publication = FeedModel.fromMap(item);
          publications.add(publication);
        }
      }
      return publications;
    } else {
      throw Exception('Não foi possível carregar as publicações. Status code: ${response.statusCode}');
    }
  }

  @override
  Future<FeedModel> getPublicationById(String publicationId, String? token) async {
    if (publicationId == null || token == null) {
      throw Exception('ID ou token nulo. Verifique as entradas.');
    }

    final response = await client.get(
      url: '${AppRoutes.feed}$publicationId',
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return FeedModel.fromMap(jsonResponse);
    } else {
      throw Exception('Falha ao carregar a publicação. Status code: ${response.statusCode}');
    }
  }

  @override
  Future<bool> addPublication(FeedModel publication, String? token) async {
    final response = await client.post(
      url: AppRoutes.feed,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(publication.toMap()),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Falha ao adicionar a publicação. Status code: ${response.statusCode}');
    }
  }

  @override
  Future<bool> updatePublication(FeedModel publication, String? token) async {
    final response = await client.put(
      url: '${AppRoutes.feed}${publication.id}',
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(publication.toMap()),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Falha ao atualizar a publicação. Status code: ${response.statusCode}');
    }
  }

  @override
  Future<bool> deletePublication(String publicationId, String? token) async {
    final response = await client.delete(
      url: '${AppRoutes.feed}$publicationId',
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Falha ao excluir a publicação. Status code: ${response.statusCode}');
    }
  }
}
