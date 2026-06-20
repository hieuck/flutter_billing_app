import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billing_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../bloc/ai_order_bloc.dart';
import '../../../../core/widgets/primary_button.dart';
import 'voice_tab.dart';
import 'text_tab.dart';
import 'photo_tab.dart';

class AiOrderPage extends StatelessWidget {
  const AiOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.aiOrder), centerTitle: true),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(icon: Icon(Icons.mic), text: AppLocalizations.of(context)!.voice),
                Tab(icon: Icon(Icons.text_fields), text: AppLocalizations.of(context)!.text),
                Tab(icon: Icon(Icons.camera_alt), text: AppLocalizations.of(context)!.photo),
              ],
            ),
            Expanded(
              child: BlocConsumer<AiOrderBloc, AiOrderState>(
                listener: (context, state) {
                  if (state is AiOrderConfirmed) {
                    context.pop(state.items);
                  }
                },
                builder: (context, state) {
                  return Stack(
                    children: [
                      const TabBarView(
                        children: [
                          VoiceTab(),
                          TextTab(),
                          PhotoTab(),
                        ],
                      ),
                      if (state is AiOrderParsed)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: _buildParsedBanner(context, state),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParsedBanner(BuildContext context, AiOrderParsed state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(AppLocalizations.of(context)!.foundItems(state.items.length),
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          PrimaryButton(
            onPressed: () =>
                context.read<AiOrderBloc>().add(ConfirmItemsEvent()),
            icon: Icons.add_shopping_cart,
            label: AppLocalizations.of(context)!.addToCart,
          ),
        ],
      ),
    );
  }
}
