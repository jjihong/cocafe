import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../controllers/towncontroller.dart';

class Town extends StatefulWidget {
  const Town({super.key});

  @override
  State<Town> createState() => _TownState();
}

class _TownState extends State<Town> {
  final TownController _townController = Get.find<TownController>();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();

  }

  void _loadData() async {
    await _townController.loadLocations();
    setState(() {}); // 로드 후 UI 갱신
  }

  void _onSearchChanged(String query) {
    setState(() {
      _townController.filterLocations(query);
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('동네 설정', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: SearchBar(
              controller: _textController,
              onChanged: _onSearchChanged,
              leading: IconButton(
                icon: const Icon(Icons.location_on),
                  onPressed: _townController.setTownFromCurrentLocation,
              ),
              hintText: '동네를 설정하세요.',
              trailing: [
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _textController.clear();
                    _onSearchChanged('');
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _townController.filteredLocations.isEmpty
                ? const Center(child: Text('검색 결과가 없습니다.'))
                : ListView.builder(
                    itemCount: _townController.filteredLocations.length,
                    itemBuilder: (context, index) {
                      final location = _townController.filteredLocations[index];
                      return ListTile(
                        title: Text(
                          "${location['시도']} ${location['시군구']} ${location['읍면동']}"
                              .trim(),
                        ),
                        onTap: () {
                          _townController.saveSelectedTown(location); // ✅ 위치 정보 전체 전달
                          Get.back();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
