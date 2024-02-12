import 'dart:convert';

import 'package:ai_voice_assistant/myInfo.dart';
import 'package:http/http.dart' as http;

class OpenAIservice {
  final List<Map<String, String>> messages = [];

  //primera función para determinar si el usuario quiere una respuesta de tipo texto o voz de chatGPT o
  //Una imagen de Dall-E
  //El prompt nos dice eso
  Future<String> isArtPromptAPI(String prompt) async {
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKey'
        },
        //Convierte los datos de dart a JSON
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'user',
              'content':
                  'Does this message want to generate an AI picture, image, art or anythin similar? $prompt. Simply answer yes or no'
            }
          ]
        }),
      );
      if (res.statusCode == 200) {
        String content =
            jsonDecode(res.body)['choices'][0]['message']['content'];

        content = content.trim();

        switch (content) {
          case 'Yes':
          case 'yes':
          case 'Yes.':
          case 'yes.':
            final res = await dallEAPI(prompt);
            return res;
          //En caso que no sea yes la respuesta
          default:
            final res = await chatGPTAPI(prompt);
            return res;
        }
      }
      return 'An internal error ocurred';
    } catch (e) {
      return e.toString();
    }
  }

  //Función para petición si el usuario quiere usar Chatgpt
  Future<String> chatGPTAPI(String prompt) async {
    //messages lo creamos con el fin que se vaya guardando la información de la conversación entre el
    // user y la AI y así tener un contexto para crear respuestas más acertadas
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKey'
        },
        //Cpnvierte los datos de dart a JSON
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': messages,
        }),
      );
      if (res.statusCode == 200) {
        String content =
            jsonDecode(res.body)['choices'][0]['message']['content'];

        content = content.trim();

        messages.add({
          'role': 'assistant',
          'content': content,
        });
        return content;
      }
      return 'An internal error ocurred';
    } catch (e) {
      return e.toString();
    }
  }

  //Función para petición si el usuario quiere usar Dall-E
  Future<String> dallEAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKey'
        },
        //Cpnvierte los datos de dart a JSON
        body: jsonEncode({
          'prompt': prompt,
          'n': 1,
        }),
      );
      if (res.statusCode == 200) {
        String imageUrl = jsonDecode(res.body)['data'][0]['url'];

        messages.add({
          'role': 'assistant',
          'content': imageUrl,
        });
        return imageUrl;
      }
      return 'An internal error ocurred';
    } catch (e) {
      return e.toString();
    }
  }
}
