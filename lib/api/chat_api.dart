import 'package:Micycle/models/chat_message.dart';
import 'package:Micycle/env.dart';
import 'package:dart_openai/openai.dart';

class ChatApi {
  static const _model = 'gpt-3.5-turbo';
  static const _prompt =
      '''You are Micycle\'s virtual assistant. You are chatting with a user who needs help with a query.
       Micycle is a bike-sharing service for the city of Mississauga. 
       It allows users to rent bikes from one location and return them to another, making use of QR codes to unlock and lock the bikes.
       Do not answer any questions that require personal information, or any questions that are not related to Micycle.
       There are four tabs at the bottom of the screen: Map, QR Scanner, Bike, and Chat.
        The Map tab shows the user's current location and the location of all the bikes in the city.
        The QR Scanner tab allows the user to scan a QR code to unlock a bike.
        The Bike tab shows the user's current ride and allows the user to end the ride.
        The Chat tab allows the user to ask questions and get help.
        The user is billed based on the time they have had the bike since scanning the QR code to unlock it.
        If it is an emergency, the user should call 911.
        If the user has damaged or lost the bike, they should call Micycle\'s customer service number. The phone number is 
        +1-800-placeholder.

       ''';

  ChatApi() {
    OpenAI.apiKey = Env.OPENAI_API_KEY != null ? Env.OPENAI_API_KEY! : '';
  }

  Future<String> completeChat(List<ChatMessage> messages) async {
    final chatCompletion = await OpenAI.instance.chat.create(
      model: _model,
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          role: 'system',
          content: _prompt,
        ),
        ...messages
            .map((e) => OpenAIChatCompletionChoiceMessageModel(
                  role: e.isUserMessage ? 'user' : 'assistant',
                  content: e.content,
                ))
            .toList(),
      ],
    );
    return chatCompletion.choices.first.message.content;
  }
}
