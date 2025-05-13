import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../models/place.dart';

class AddressSearchScreen extends StatefulWidget {
  const AddressSearchScreen({Key? key}) : super(key: key);

  @override
  _AddressSearchScreenState createState() => _AddressSearchScreenState();
}

class _AddressSearchScreenState extends State<AddressSearchScreen> {
  final _searchCtrl = TextEditingController();
  final _results = <Place>[];
  bool _loading = false;

  static final String _restApiKey = dotenv.get('KAKAO_REST_API_KEY');

  Future<void> search() async {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) return;
    setState(() => _loading = true);
    final uri = Uri.https(
        'dapi.kakao.com', '/v2/local/search/keyword.json', {'query': q});
    final resp = await http.get(uri, headers: {'Authorization': _restApiKey});
    if (resp.statusCode == 200) {
      final body = json.decode(resp.body) as Map<String, dynamic>;
      final docs = (body['documents'] as List).cast<Map<String, dynamic>>();
      setState(() {
        _results
          ..clear()
          ..addAll(docs.map((j) => Place.fromJson(j)));
      });
    } else {
      Get.snackbar('검색 실패', 'HTTP ${resp.statusCode}');
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: const Text('주소 검색')),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  decoration: const InputDecoration(
                    hintText: '장소명 입력',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => search(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: search, child: const Text('검색')),
            ]),
          ),
          if (_loading) const LinearProgressIndicator(),
          Expanded(
            child: _results.isEmpty
                ? const Center(child: Text('검색 결과가 없습니다.'))
                : ListView.separated(
                    itemCount: _results.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, i) {
                      final p = _results[i];
                      return ListTile(
                        title: Text(p.name),
                        subtitle: Text(p.roadAddress ?? p.address),
                        trailing: p.phone == null ? null : Text(p.phone!),
                        onTap: () {
                          Get.back(result: p);
                        },
                      );
                    },
                  ),
          ),
        ]),
      );
}
