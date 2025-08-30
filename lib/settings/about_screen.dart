import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About SouqNote"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const Icon(Icons.shopping_bag, size: 60, color: Colors.blue),
                  const SizedBox(height: 12),
                  Text(
                    "SouqNote",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Version 1.0.0",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "About",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              "SouqNote is a simple and intuitive sales & inventory "
              "management application designed for small businesses and personal use. "
              "Track sales, manage inventory, and analyze profits with ease.",
            ),
            const SizedBox(height: 24),
            Text(
              "Developer",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text("Developed by Yohannes Tsegaye"),
            const Text("Email: yohantse121@gmail.com"),
            const SizedBox(height: 24),
            Text(
              "License",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              "This app is free to use for small businesses. "
              "Future versions may include premium features.",
            ),
          ],
        ),
      ),
    );
  }
}
