import 'package:flutter/material.dart';
import 'package:store/core/theme/burhan_colors.dart';
import 'package:store/core/widgets/bottom_nav.dart';
import 'package:store/core/widgets/top_header.dart';
import 'package:store/features/cart/presentation/pages/cart_page.dart';
import 'package:store/features/home/presentation/pages/home_page.dart';
import 'package:store/features/orders/presentation/pages/orders_page.dart';
import 'package:store/features/products/presentation/pages/products_page.dart';
import 'package:store/features/profile/presentation/pages/profile_page.dart';

/// Main application scaffold housing TopHeader, tab views, and BottomNav.
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key, this.initialTab = MainTab.home});

  final MainTab initialTab;

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late MainTab _currentTab;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  String? get _headerTitle => switch (_currentTab) {
        MainTab.home => null,
        MainTab.search => 'البحث والرابط',
        MainTab.cart => 'سلة التسوق',
        MainTab.orders => 'طلباتي والشحنات',
        MainTab.profile => 'الملف الشخصي',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BurhanColors.background,
      appBar: TopHeader(
        title: _headerTitle,
        showBack: _currentTab != MainTab.home,
        onBack: () => setState(() => _currentTab = MainTab.home),
        onNotificationTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('مركز الإشعارات والتنبيهات'),
              duration: Duration(milliseconds: 1500),
              backgroundColor: BurhanColors.slate900,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
      body: IndexedStack(
        index: _currentTab.index,
        children: const [
          HomePage(),
          ProductsPage(),
          CartPage(),
          OrdersPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentTab: _currentTab,
        onTabSelected: (tab) => setState(() => _currentTab = tab),
        cartCount: 2,
        activeOrdersCount: 3,
      ),
    );
  }
}
