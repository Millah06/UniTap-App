// lib/widgets/reward_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/post_model.dart';
import '../providers/reward_provider.dart';
import '../providers/feed_provider.dart';

class RewardBottomSheet extends StatefulWidget {
  final Post post;

  const RewardBottomSheet({Key? key, required this.post}) : super(key: key);

  @override
  State<RewardBottomSheet> createState() => _RewardBottomSheetState();
}

class _RewardBottomSheetState extends State<RewardBottomSheet> {
  final TextEditingController _amountController = TextEditingController();
  bool _isProcessing = false;
  double? _selectedAmount;

  final List<double> _quickAmounts = [50, 100, 200, 500, 1000];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _processReward() async {
    final amount = _selectedAmount ?? double.tryParse(_amountController.text);

    if (amount == null || amount < 10) {
      _showError('Minimum reward is ₦10');
      return;
    }

    if (amount > 10000) {
      _showError('Maximum reward is ₦10,000');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final response = await context.read<RewardProvider>().rewardPost(
        widget.post.postId,
        amount,
      );

      if (mounted) {
        // Update post in feed
        context.read<FeedProvider>().updatePostAfterReward(
          widget.post.postId,
          widget.post.rewardCount + 1,
          widget.post.rewardPointsTotal + (response['pointsAwarded'] ?? 0),
        );

        Navigator.pop(context);
        _showSuccess(
          '₦${amount.toStringAsFixed(0)} rewarded! '
              'Creator earned ${response['pointsAwarded']?.toStringAsFixed(0)} points.',
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.card_giftcard, color: Colors.blue[700]),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reward Creator',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '5% platform fee applies',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick amounts
              const Text(
                'Quick Select',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickAmounts.map((amount) {
                  final isSelected = _selectedAmount == amount;
                  return ChoiceChip(
                    label: Text('₦${amount.toStringAsFixed(0)}'),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedAmount = selected ? amount : null;
                        _amountController.clear();
                      });
                    },
                    selectedColor: Colors.blue[700],
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Custom amount
              const Text(
                'Or enter custom amount',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  prefixText: '₦',
                  hintText: '0',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedAmount = null;
                  });
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Min: ₦10 • Max: ₦10,000',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Reward button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processReward,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                      : const Text(
                    'Send Reward',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}