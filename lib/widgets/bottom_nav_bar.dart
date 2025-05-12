import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color navBg = Theme.of(context).colorScheme.surface;
    final Color selected = Theme.of(context).colorScheme.primary;
    final Color unselected = Colors.grey;
    return BottomAppBar(
      color: navBg,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.home_filled,
                color: currentIndex == 0 ? selected : unselected,
                size: 28,
              ),
              tooltip: 'Home',
              onPressed: () => onTap(0),
            ),
            IconButton(
              icon: Icon(
                Icons.book_rounded,
                color: currentIndex == 1 ? selected : unselected,
                size: 26,
              ),
              tooltip: 'Diary',
              onPressed: () => onTap(1),
            ),
            IconButton(
              icon: Icon(Icons.add_circle, color: selected, size: 36),
              tooltip: 'Add Task',
              onPressed: () => onTap(2),
            ),
            IconButton(
              icon: Icon(Icons.code_rounded, color: unselected, size: 26),
              tooltip: 'GitHub',
              onPressed: () => _launchUrl('https://github.com/Harshad-Gore'),
            ),
            IconButton(
              icon: Icon(
                Icons.business_center_rounded,
                color: unselected,
                size: 26,
              ),
              tooltip: 'LinkedIn',
              onPressed:
                  () =>
                      _launchUrl('https://www.linkedin.com/in/harshad-s-gore'),
            ),
          ],
        ),
      ),
    );
  }
}
