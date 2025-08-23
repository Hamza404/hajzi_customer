import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajzi/theme/font_styles.dart';
import 'package:intl/intl.dart' as intl;
import 'bloc/chat_cubit.dart';
import 'bloc/chat_state.dart';

class UserChatScreen extends StatefulWidget {

  const UserChatScreen({super.key});

  static Widget builder(BuildContext context) {
    return BlocProvider<ChatCubit>(
      create: (context) => ChatCubit(),
      child: const UserChatScreen(),
    );
  }

  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  final TextEditingController _controller = TextEditingController();
  late int orderId;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToLatest() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (msgDate == today) return "Today";
    if (msgDate == yesterday) return "Yesterday";
    return intl.DateFormat('d MMM yyyy').format(dateTime);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderId = ModalRoute.of(context)!.settings.arguments as int;
      context.read<ChatCubit>().chatInitiate(orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ChatAppBar(),
      backgroundColor: Colors.white,
      body: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          return Directionality(textDirection: TextDirection.ltr, child: Column(
            children: [

              Expanded(
                child: () {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.error != null) {
                    return Center(child: Text(state.error!));
                  }

                  return RefreshIndicator(
                    color: Colors.black,
                    onRefresh: () async {
                      await context.read<ChatCubit>().fetchChatHistory(orderId);
                    },
                    child: ListView.builder(
                      reverse: true,
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final message = state.messages[index];
                        final isMe = message.messageFrom == state.chatInitiate?.userId;

                        final sentTime = DateTime.parse(message.sentTime);

                        bool showDateDivider = false;
                        if (index == state.messages.length - 1) {
                          showDateDivider = true;
                        } else {
                          final prevMessage = state.messages[index + 1];
                          final prevDate = DateTime.parse(prevMessage.sentTime);
                          if (prevDate.day != sentTime.day ||
                              prevDate.month != sentTime.month ||
                              prevDate.year != sentTime.year) {
                            showDateDivider = true;
                          }
                        }

                        return Column(
                          children: [
                            if (showDateDivider)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      formatDate(sentTime),
                                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                                    ),
                                  ),
                                ),
                              ),
                            Align(
                              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.all(12),
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                                ),
                                decoration: BoxDecoration(
                                  color: isMe ? Colors.blue : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  message.messageText,
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  );
                } (),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: "Write your message...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.blue,
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: () {
                            if (_controller.text.trim().isEmpty) return;

                            final chatId = state.chatInitiate?.id ?? 0;

                            context.read<ChatCubit>().sendMessage(
                                _controller.text.trim(),
                                chatId,
                                state.chatInitiate?.userId ?? 0,
                                state.chatInitiate?.businessId ?? 0
                            ).then((onValue) {
                              _scrollToLatest();
                            });
                            _controller.clear();
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          );
        },
      ),
    );
  }
}

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {

  const ChatAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection: TextDirection.ltr, child: AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      scrolledUnderElevation: 0,
      leading: Directionality(textDirection: TextDirection.ltr, child: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      )),
      title: BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            return Text(
              state.chatInitiate?.businessName ?? '',
              style: FontStyles.fontW400.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            );
          }),
      centerTitle: false,
    ));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}