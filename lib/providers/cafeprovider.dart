import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cafemodel.dart';

/// REST API로부터 카페 데이터를 가져오는 클래스
/// 역할: 외부 API 호출, JSON 데이터를 CafeModel로 변환
class CafeProvider {
  /// API의 기본 URL
  static const String baseUrl = 'https://cocafe-api.vercel.app/api';

  /// 모든 카페 정보를 가져오는 메서드
  /// 반환값: CafeModel 객체들의 리스트
  /// 예외: 네트워크 오류 시 예외 발생
  Future<List<CafeModel>> fetchAllCafes() async {
    try {
      // 1. HTTP GET 요청 보내기
      final response = await http.get(
        Uri.parse('$baseUrl/cafes'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // 2. 응답 상태 확인 (200 = 성공)
      if (response.statusCode == 200) {
        // 3. JSON 문자열을 Dart 객체로 변환
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        // 4. 'data' 필드에서 카페 배열 추출
        final List<dynamic> jsonList = jsonResponse['data'] as List<dynamic>;
        
        // 5. JSON 배열을 CafeModel 리스트로 변환
        final List<CafeModel> cafes = jsonList
            .map((json) => CafeModel.fromJson(json))
            .toList();
        
        print('카페 ${cafes.length}개 불러오기 성공');
        return cafes;
        
      } else {
        // 5. HTTP 오류 처리
        throw Exception('카페 데이터 로드 실패: ${response.statusCode}');
      }
      
    } catch (e) {
      // 6. 네트워크 오류나 기타 예외 처리
      print('카페 데이터 로드 중 오류: $e');
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 추천 카페 정보를 가져오는 메서드 (옵션)
  /// 반환값: 평점 높은 순서로 정렬된 CafeModel 리스트
  Future<List<CafeModel>> fetchRecommendedCafes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cafes/recommend/top-rated'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> jsonList = jsonResponse['data'] as List<dynamic>;
        final List<CafeModel> cafes = jsonList
            .map((json) => CafeModel.fromJson(json))
            .toList();
        
        print('추천 카페 ${cafes.length}개 불러오기 성공');
        return cafes;
        
      } else {
        throw Exception('추천 카페 데이터 로드 실패: ${response.statusCode}');
      }
      
    } catch (e) {
      print('추천 카페 데이터 로드 중 오류: $e');
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 특정 카페의 상세 정보를 가져오는 메서드
  /// 매개변수: cafeId - 조회할 카페의 ID
  /// 반환값: 해당 카페의 CafeModel 객체, 없으면 null
  Future<CafeModel?> fetchCafeById(int cafeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cafes/$cafeId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final cafe = CafeModel.fromJson(json);
        
        print('카페 ID $cafeId 상세 정보 불러오기 성공');
        return cafe;
        
      } else if (response.statusCode == 404) {
        print('카페 ID $cafeId를 찾을 수 없음');
        return null;
        
      } else {
        throw Exception('카페 상세 정보 로드 실패: ${response.statusCode}');
      }
      
    } catch (e) {
      print('카페 상세 정보 로드 중 오류: $e');
      throw Exception('네트워크 오류: $e');
    }
  }
}