
import 'package:equatable/equatable.dart';
import 'package:hajzi/presentation/chat/model/user_chat_listing.dart';
import '../model/chat_message.dart';

class ChatState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<ChatMessage> messages;
  final ChatInitiate? chatInitiate;
  final List<UserChatListing> chatListing;
  final bool isListingLoading;

  const ChatState({
    this.isLoading = false,
    this.error,
    this.messages = const [],
    this.chatInitiate,
    this.chatListing = const [],
    this.isListingLoading = false
  });

  ChatState copyWith({
    bool? isLoading,
    String? error,
    List<ChatMessage>? messages,
    ChatInitiate? chatInitiate,
    List<UserChatListing>? chatListing,
    bool? isListingLoading
  }) {
    return ChatState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        messages: messages ?? this.messages,
        chatInitiate: chatInitiate ?? this.chatInitiate,
        chatListing : chatListing ?? this.chatListing,
        isListingLoading : isListingLoading ?? this.isListingLoading
    );
  }

  @override
  List<Object?> get props => [isLoading, error, messages, chatInitiate, chatListing, isListingLoading];
}