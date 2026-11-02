import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class GeminiService {
  // NOTE: Replace with your actual Gemini API key
  static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent';

  Future<GeminiAnalysisResult> analyzeImage(File imageFile) async {
    try {
      // Read image bytes and convert to base64
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      // Prepare the request payload
      final payload = {
        'contents': [
          {
            'parts': [
              {
                'text': '''Analyze this image. Identify if it contains a civic issue: pothole, garbage, or streetlight problem.
Return strictly JSON only with this exact format:
{
  "valid": true/false,
  "type": "pothole" | "garbage" | "streetlight" | null,
  "severity": "low" | "medium" | "high" | null,
  "description": "brief description" | null
}

Rules:
- Set "valid" to false if the image contains people, animals, selfies, or irrelevant content
- Only set "valid" to true if you detect a clear civic infrastructure issue
- For valid images, provide type, severity, and description
- For invalid images, set type, severity, and description to null'''
              },
              {
                'inline_data': {
                  'mime_type': 'image/jpeg',
                  'data': base64Image
                }
              }
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.4,
          'topK': 32,
          'topP': 1,
          'maxOutputTokens': 2048,
        }
      };

      // Make the API request
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode != 200) {
        throw Exception('Gemini API error: ${response.statusCode} - ${response.body}');
      }

      // Parse the response
      final data = jsonDecode(response.body);
      final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
      
      // Extract JSON from the response (remove markdown code blocks if present)
      String jsonText = text.trim();
      if (jsonText.startsWith('```json')) {
        jsonText = jsonText.substring(7);
      }
      if (jsonText.startsWith('```')) {
        jsonText = jsonText.substring(3);
      }
      if (jsonText.endsWith('```')) {
        jsonText = jsonText.substring(0, jsonText.length - 3);
      }
      jsonText = jsonText.trim();

      final resultJson = jsonDecode(jsonText);
      
      return GeminiAnalysisResult.fromJson(resultJson);
    } catch (e) {
      print('Error analyzing image with Gemini: $e');
      rethrow;
    }
  }
}

class GeminiAnalysisResult {
  final bool valid;
  final String? type;
  final String? severity;
  final String? description;

  GeminiAnalysisResult({
    required this.valid,
    this.type,
    this.severity,
    this.description,
  });

  factory GeminiAnalysisResult.fromJson(Map<String, dynamic> json) {
    return GeminiAnalysisResult(
      valid: json['valid'] as bool,
      type: json['type'] as String?,
      severity: json['severity'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'valid': valid,
      'type': type,
      'severity': severity,
      'description': description,
    };
  }
}
