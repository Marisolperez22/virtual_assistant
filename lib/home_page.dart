import 'package:ai_voice_assistant/feature_box.dart';
import 'package:ai_voice_assistant/openai_service.dart';
import 'package:ai_voice_assistant/pallete.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? generatedContent;
  String? generatedImageUrl;
  final flutterTts = FlutterTts();
  final OpenAIservice openAiService = OpenAIservice();
  final speechToText = SpeechToText();
  bool speechEnabled = false;
  String lastWords = '';
  int start = 200;
  int delay = 200;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  //Esta activa el plugin cuando se abre la app por primer vez
  Future<void> initSpeechToText() async {
    speechEnabled = await speechToText.initialize();
    //Esto reconstruye la función rebuild
    setState(() {});
  }

  //Esta escucha al usuario y ejecuta la función onSpeechResult al mismo tiempo
  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  //Desactiva la función de escuchar (SpeechtoText)
  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  //Luego de escuchar al usuario, se guarda lo que dijo en una variable lastwords
  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  //Desactiva la escucha
  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  //Funcion para que se lea en voz alta la resouesta de chatgpt
  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  @override
  Widget build(BuildContext context) {
    final DateTime dayTime = DateTime.now();
    Widget buildGreetingWidget(DateTime dayTime) {
      Widget greetingWidget;

      if (dayTime.hour > 0 && dayTime.hour < 12) {
        greetingWidget = const Text('Good Morning');
      } else if (dayTime.hour >= 12 && dayTime.hour < 19) {
        greetingWidget = const Text('Good Afternoon');
      } else if (dayTime.hour >= 19 && dayTime.hour < 24) {
        greetingWidget = const Text('Good night');
      } else {
        greetingWidget = const SizedBox();
      }

      return greetingWidget;
    }

    String? hourGreeting = (buildGreetingWidget(dayTime) as Text).data;

    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(child: const Text('Eva')),
        leading: const Icon(Icons.menu),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          //Virtual assistant picture
          ZoomIn(
            child: Stack(
              children: [
                Center(
                  child: Container(
                    height: 120,
                    width: 120,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                        color: Pallete.assistantCircleColor,
                        shape: BoxShape.circle),
                  ),
                ),
                Container(
                  height: 170,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: AssetImage('assets/images/assistante.png'))),
                )
              ],
            ),
          ),
          //chat bubble
          FadeInRight(
            child: Container(
              //no vamos a poner un height específico porque si el widget de abajo es más grande dependiendo de la respuesta
              //Va a causar un problema. En este caso sólo dejamos un padding
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                  border: Border.all(color: Pallete.borderColor),
                  borderRadius: BorderRadius.circular(20).copyWith(
                    topLeft: Radius.zero,
                  )),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  generatedContent == null
                      ? '$hourGreeting, what can I do for you?'
                      : generatedContent!,
                  style: TextStyle(
                    color: Pallete.mainFontColor,
                    fontSize: generatedContent == null ? 20 : 18,
                    fontFamily: 'Cera Pro',
                  ),
                ),
              ),
            ),
          ),
          if (generatedImageUrl != null)
            Padding(
                padding: const EdgeInsets.all(10),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(generatedImageUrl!))),
          SlideInLeft(
            child: Visibility(
              visible: generatedContent == null && generatedImageUrl == null,
              child: Container(
                padding: const EdgeInsets.only(left: 5, right: 5),
                margin: const EdgeInsets.only(
                  top: 10,
                  left: 22,
                ),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Here are a few features',
                  style: TextStyle(
                      fontFamily: 'Cera Pro',
                      color: Pallete.mainFontColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          //features List
          //Si el generatedContent es nulo, entonces muestra la columna
          Visibility(
            visible: generatedContent == null && generatedImageUrl == null,
            child: Column(
              children: [
                SlideInLeft(
                  delay: Duration(milliseconds: start),
                  child: const FeatureBox(
                    color: Pallete.firstSuggestionBoxColor,
                    headerText: 'ChatGPT',
                    descriptionText:
                        'A smarter way to stay organized and informed with ChatGPT',
                  ),
                ),
                SlideInLeft(
                  delay: Duration(milliseconds: start + delay),
                  child: const FeatureBox(
                      color: Pallete.secondSuggestionBoxColor,
                      headerText: 'Dall-E',
                      descriptionText:
                          'Get inspired and stay creative with your personal assistant powered by Dall-E'),
                ),
                SlideInLeft(
                  delay: Duration(milliseconds: start + 2 * delay),
                  child: const FeatureBox(
                      color: Pallete.thirdSuggestionBoxColor,
                      headerText: 'Smart Voice Assistant',
                      descriptionText:
                          'Get the best of both worlds with a voice assistant powered by Dall-E and chatGPT'),
                ),
              ],
            ),
          ),
        ]),
      ),
      floatingActionButton: ZoomIn(
        delay: Duration(milliseconds: start + 3 * delay),
        child: FloatingActionButton(
          shape: const CircleBorder(),
          onPressed: () async {
            if (await speechToText.hasPermission &&
                speechToText.isNotListening) {
              await startListening();
            } else if (speechToText.isListening) {
              final speech = await openAiService.isArtPromptAPI(lastWords);
              if (speech.contains('hppts')) {
                generatedImageUrl = speech;
                //Este generatedcontent se pone porque se sipone que el usuario primero obtiene datos de la chatgpt
                //luego el usuario obtiene la imagen de Dall-E, lo ponemos null porque solo vamos a recibir
                //la imagen y no contenido de la solicitud
                generatedContent = null;
                setState(() {});
              } else {
                generatedImageUrl = null;
                generatedContent = speech;
                await systemSpeak(speech);
                //Setstate se necesita porque ya se le dieron valores iniciales a las variables
                //Luego que cambian, se vuelve a creaar la screen
                setState(() {});
              }
              await stopListening();
            } else {
              initSpeechToText();
            }
          },
          child: Icon(speechToText.isListening ? Icons.stop : Icons.mic),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
