import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/assistant_bloc.dart';

class AssistantPage extends StatelessWidget {
  const AssistantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<AssistantBloc>().add(ClearChatEvent()),
          ),
        ],
      ),
      body: BlocBuilder<AssistantBloc, AssistantState>(
        builder: (context, state) {
          if (state is AssistantInitial) {
            return _buildEmptyState(context);
          }
          if (state is AssistantAnswered) {
            return _buildChat(context, state.messages);
          }
          return _buildChat(context, []);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.smart_toy, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text('Ask me about your business!',
              style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          const Text('Try: "Doanh thu hôm nay?"',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _suggestionChip(context, 'Doanh thu hôm nay?'),
              _suggestionChip(context, 'Chi phí tháng này?'),
              _suggestionChip(context, 'Lợi nhuận?'),
              _suggestionChip(context, 'Sản phẩm bán chạy?'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _suggestionChip(BuildContext context, String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        context.read<AssistantBloc>().add(AskQuestionEvent(text));
      },
    );
  }

  Widget _buildChat(BuildContext context, List<ChatMessage> messages) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              return _buildMessageBubble(context, msg);
            },
          ),
        ),
        BlocBuilder<AssistantBloc, AssistantState>(
          builder: (context, state) {
            if (state is AssistantLoading) {
              return const Padding(
                padding: EdgeInsets.all(8),
                child: LinearProgressIndicator(),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        _buildInputBar(context),
      ],
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: msg.isUser ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: msg.isUser ? const Radius.circular(4) : null,
            bottomLeft: msg.isUser ? null : const Radius.circular(4),
          ),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(msg.text),
      ),
    );
  }

  Widget _buildInputBar(BuildContext context) {
    final controller = TextEditingController();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Ask a question...',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  context.read<AssistantBloc>().add(AskQuestionEvent(value));
                  controller.clear();
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            color: Colors.blue,
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<AssistantBloc>()
                    .add(AskQuestionEvent(controller.text));
                controller.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
