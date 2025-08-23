import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajzi/core/localization/app_localization.dart';
import 'package:hajzi/presentation/chat/bloc/chat_cubit.dart';
import 'package:hajzi/presentation/chat/bloc/chat_state.dart';
import 'package:hajzi/theme/font_styles.dart';

import '../../core/utils/navigator_service.dart';
import '../../routes/app_routes.dart';

class UserChatListingScreen extends StatefulWidget {
  const UserChatListingScreen({super.key});

  static Widget builder(BuildContext context) {
    return BlocProvider<ChatCubit>(
      create: (context) => ChatCubit()..fetchChatList(true),
      child: const UserChatListingScreen(),
    );
  }

  @override
  State<UserChatListingScreen> createState() => _UserChatListingState();
}

class _UserChatListingState extends State<UserChatListingScreen> {

  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 56, left: 16, right: 16),
              child: Text('chats'.tr,
                  style: FontStyles.fontW800.copyWith(fontSize: 36)),
            ),
            Container(
              margin: const EdgeInsets.only(top: 8, left: 16, right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.search, color: Colors.grey),
                    hintText: "search".tr,
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  }
              ),
            ),

            Expanded(child: BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  if (state.isListingLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final filteredChats = state.chatListing.where((chat) {
                    return chat.businessName.toLowerCase().contains(searchQuery.toLowerCase());
                  }).toList();

                  return RefreshIndicator(
                    color: Colors.black,
                    onRefresh: () async {
                      await context.read<ChatCubit>().fetchChatList(false);
                    },
                    child: filteredChats.isEmpty
                        ? const Center(child: Text("No chats found"))
                        : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: filteredChats.length,
                      separatorBuilder: (_, __) =>
                      const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final chat = filteredChats[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: SizedBox(
                            width: 40,
                            height: 40,
                            child: ClipOval(
                              child: Image.asset(
                                "assets/ic_chat.png",
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          title: Text(
                            chat.businessName,
                            style: FontStyles.fontW500.copyWith(fontSize: 16),
                          ),
                          onTap: () {
                            NavigatorService.pushNamed(AppRoutes.chatScreen, arguments: chat.orderId);
                          },
                        );
                      },
                    ),
                  );
                }
            ))
          ],
        )
    );
  }
}