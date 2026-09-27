import '../../../core/network/api_client.dart';
import 'note_model.dart';

class NoteRepository {
  final ApiClient _apiClient;
  NoteRepository(this._apiClient);

  Future<List<NoteModel>> search(String? query) async {
    final response = await _apiClient.dio.get('/notes', queryParameters: {
      if (query != null && query.isNotEmpty) 'q': query,
      'page': 1,
      'pageSize': 50,
    });
    final items = (response.data as Map<String, dynamic>)['items'] as List;
    return items.map((e) => NoteModel.fromJson(e)).toList();
  }

  Future<void> create({required String title, String? contentRichText, String noteType = 'text'}) async {
    await _apiClient.dio.post('/notes', data: {
      'title': title,
      'contentRichText': contentRichText,
      'noteType': noteType,
    });
  }

  Future<void> delete(String id) => _apiClient.dio.delete('/notes/$id');
}
