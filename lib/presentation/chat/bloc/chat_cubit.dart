import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajzi/presentation/chat/model/user_chat_listing.dart';
import '../../../client/api_manager.dart';
import '../model/chat_message.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(const ChatState());

  Future<void> chatInitiate(int orderId) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final response = await ApiManager.get('UserChat/ChatInitiate?orderId=$orderId');
      if (response['isSuccess'] == true) {
        await fetchChatHistory(orderId);

        final data = ChatInitiate.fromJson(response['content']);

        emit(state.copyWith(isLoading: false, chatInitiate: data));

      } else {
        emit(state.copyWith(
            isLoading: false,
            error: 'Something went wrong'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> fetchChatHistory(int orderId) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final response = await ApiManager.get('UserChat/ChatHistory?orderId=$orderId');
      if (response['isSuccess'] == true && response['content'] is List) {
        final chats = (response['content'] as List)
            .map((e) => ChatMessage.fromJson(e))
            .toList();

        emit(state.copyWith(isLoading: false, messages: chats));
      } else {
        emit(state.copyWith(
            isLoading: false,
            error: response['messages']?.toString() ?? 'Unknown error'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> sendMessage(String messageText, int chatId, int fromUserId, int toUserId) async {
    if (messageText.trim().isEmpty) return;

    try {
      final body = {
        "chatId": chatId,
        "messageText": messageText,
      };

      final response = await ApiManager.post('UserChat/Send', body: body);

      if (response['isSuccess'] == true) {
        final newMessage = ChatMessage(
          messageFrom: fromUserId,
          messageTo: toUserId,
          chatId: chatId,
          messageText: messageText,
          sentTime: getCurrentTimestamp(),
        );

        final updatedList = List<ChatMessage>.from(state.messages)..insert(0, newMessage);
        emit(state.copyWith(messages: updatedList));
      } else {
        emit(state.copyWith(error: response['messages']?.toString() ?? 'Failed to send'));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> fetchChatList(bool loading) async {
    emit(state.copyWith(isListingLoading: loading, error: null));
    try {
      final response = await ApiManager.get('UserChat');
      if (response['isSuccess'] == true && response['content'] is List) {
        final chats = (response['content'] as List)
            .map((e) => UserChatListing.fromJson(e))
            .toList();
        emit(state.copyWith(isListingLoading: false, chatListing: chats));
      } else {
        emit(state.copyWith(
          isListingLoading: false,
          error: response['messages']?.toString() ?? 'Unknown error',
        ));
      }
    } catch (e) {
      emit(state.copyWith(isListingLoading: false, error: e.toString()));
    }
  }

  String getCurrentTimestamp() {
    final now = DateTime.now().toUtc();
    final isoString = now.toIso8601String();
    final withExtraPrecision = isoString.replaceFirstMapped(
      RegExp(r'\.(\d{6})'),
          (match) => '.${match[1]}1',
    );
    return withExtraPrecision.replaceFirst('Z', '+00:00');
  }
}