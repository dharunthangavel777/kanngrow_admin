import 'package:flutter/material.dart';

class ValidationScreen extends StatelessWidget {
  const ValidationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Validation Engine Reports', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(flex: 3, child: Text('BUSINESS IDEA', style: _headerStyle(context))),
                        Expanded(flex: 2, child: Text('MARKET SCORE', style: _headerStyle(context))),
                        Expanded(flex: 2, child: Text('COMPETITION', style: _headerStyle(context))),
                        Expanded(flex: 2, child: Text('RISK LEVEL', style: _headerStyle(context))),
                        Expanded(flex: 1, child: Text('ACTION', style: _headerStyle(context))),
                      ],
                    ),
                    const Divider(height: 32),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 8,
                      separatorBuilder: (_, __) => const Divider(height: 32),
                      itemBuilder: (context, index) {
                        return _ValidationRow(
                          ideaName: 'Eco-Friendly Tech Accessories ${index + 1}',
                          marketScore: 90 - (index * 4),
                          competitionScore: 60 + (index * 5),
                          riskLevel: index % 3 == 0 ? 'High' : (index % 2 == 0 ? 'Low' : 'Medium'),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _headerStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        );
  }
}

class _ValidationRow extends StatelessWidget {
  final String ideaName;
  final int marketScore;
  final int competitionScore;
  final String riskLevel;

  const _ValidationRow({
    required this.ideaName,
    required this.marketScore,
    required this.competitionScore,
    required this.riskLevel,
  });

  Color _getRiskColor() {
    switch (riskLevel) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(ideaName, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          flex: 2,
          child: Text('$marketScore/100', style: TextStyle(color: marketScore > 75 ? Colors.green : Colors.orange, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          flex: 2,
          child: Text('$competitionScore/100', style: TextStyle(color: competitionScore > 70 ? Colors.red : Colors.green)),
        ),
        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getRiskColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                riskLevel,
                style: TextStyle(color: _getRiskColor(), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              onPressed: () {},
            ),
          ),
        ),
      ],
    );
  }
}
