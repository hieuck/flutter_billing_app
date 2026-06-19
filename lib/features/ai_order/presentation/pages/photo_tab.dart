import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../bloc/ai_order_bloc.dart';

class PhotoTab extends StatelessWidget {
  const PhotoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text('Take a photo of a menu or order list',
              style: TextStyle(fontSize: 16)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              context.read<AiOrderBloc>().add(
                    const ParseTextEvent('Demo item from photo'),
                  );
            },
            icon: const Icon(Icons.camera),
            label: const Text('Take Photo'),
          ),
        ],
      ),
    );
  }
}
