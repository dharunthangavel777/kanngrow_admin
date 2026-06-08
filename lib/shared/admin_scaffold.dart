import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminScaffold extends StatelessWidget {
  final Widget child;
  const AdminScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              title: const Text('Kangrow Admin'),
            ),
      drawer: isDesktop ? null : Drawer(child: _Sidebar(onTap: () => Navigator.pop(context))),
      body: Row(
        children: [
          if (isDesktop) const SizedBox(width: 250, child: _Sidebar()),
          if (isDesktop) const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final VoidCallback? onTap;

  const _Sidebar({this.onTap});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;

    return Container(
      color: Theme.of(context).canvasColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            child: Row(
              children: [
                Image.asset(
                  'assets/logos/logo_without_text.png',
                  height: 24,
                  width: 24,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 8),
                Text(
                  'KANGROW ADMIN',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          
          _SectionHeader(title: 'CORE'),
          _NavItem(title: 'Dashboard', icon: Icons.dashboard, route: '/', currentPath: location, onTap: onTap),
          _NavItem(title: 'Users', icon: Icons.people, route: '/users', currentPath: location, onTap: onTap),
          _NavItem(title: 'Businesses', icon: Icons.storefront, route: '/ecommerce', currentPath: location, onTap: onTap),
          
          _SectionHeader(title: 'ENGINES'),
          _NavItem(title: 'Product Ideas', icon: Icons.lightbulb_outline, route: '/ideas', currentPath: location, onTap: onTap),
          _NavItem(title: 'Validation', icon: Icons.fact_check_outlined, route: '/validation', currentPath: location, onTap: onTap),
          _NavItem(title: 'Roadmaps', icon: Icons.map_outlined, route: '/roadmaps', currentPath: location, onTap: onTap),
          
          _SectionHeader(title: 'AI & DATA'),
          _NavItem(title: 'Platform Context', icon: Icons.push_pin_outlined, route: '/platform-context', currentPath: location, onTap: onTap),
          _NavItem(title: 'User DNA Insights', icon: Icons.insights_outlined, route: '/user-dna', currentPath: location, onTap: onTap),
          _NavItem(title: 'AI Cost Center', icon: Icons.memory, route: '/ai', currentPath: location, onTap: onTap),
          _NavItem(title: 'Hot News', icon: Icons.local_fire_department_rounded, route: '/hot-news', currentPath: location, onTap: onTap),
          _NavItem(title: 'Chat Logs', icon: Icons.chat_bubble_outline, route: '/chat', currentPath: location, onTap: onTap),
          _NavItem(title: 'Analytics', icon: Icons.bar_chart, route: '/analytics', currentPath: location, onTap: onTap),
          
          _SectionHeader(title: 'MANAGEMENT'),
          _NavItem(title: 'Subscriptions', icon: Icons.payment, route: '/subscriptions', currentPath: location, onTap: onTap),
          _NavItem(title: 'Notifications', icon: Icons.campaign_outlined, route: '/notifications', currentPath: location, onTap: onTap),
          _NavItem(title: 'Feedback & Support', icon: Icons.support_agent, route: '/feedback', currentPath: location, onTap: onTap),
          
          _SectionHeader(title: 'SYSTEM'),
          _NavItem(title: 'Settings', icon: Icons.settings, route: '/settings', currentPath: location, onTap: onTap),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final String route;
  final String currentPath;
  final VoidCallback? onTap;

  const _NavItem({
    required this.title,
    required this.icon,
    required this.route,
    required this.currentPath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = currentPath == route;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        selected: isSelected,
        selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
        leading: Icon(
          icon,
          color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        onTap: () {
          if (onTap != null) onTap!();
          context.go(route);
        },
      ),
    );
  }
}
