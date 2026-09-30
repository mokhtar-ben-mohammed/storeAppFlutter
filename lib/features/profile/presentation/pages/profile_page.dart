import 'package:flutter/material.dart';
import 'package:store/core/theme/burhan_colors.dart';
import 'package:store/core/theme/burhan_typography.dart';
import 'package:store/core/widgets/burhan_bottom_sheet.dart';
import 'package:store/core/widgets/profile_menu_tile.dart';

/// Profile & Account screen matching ProfileScreen.tsx in storeAppUI.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = 'عميل برهان';
  String _userCity = 'صنعاء';
  String _selectedCurrency = 'YER';
  String _selectedLanguage = 'ar';
  String _selectedTheme = 'light';
  bool _notificationsEnabled = true;

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: BurhanTypography.bodySmall.copyWith(color: Colors.white),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: BurhanColors.slate900,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // 1. CURRENCY BOTTOM SHEET
  void _openCurrencySheet() {
    final options = [
      {'id': 'YER', 'label': 'ريال يمني', 'code': 'YER', 'flag': '🇾🇪', 'desc': 'العملة الرسمية للتسوق والتوصيل في اليمن'},
      {'id': 'SAR', 'label': 'ريال سعودي', 'code': 'SAR', 'flag': '🇸🇦', 'desc': 'الريال السعودي المعتمد للحوالات'},
      {'id': 'USD', 'label': 'دولار أمريكي', 'code': 'USD', 'flag': '🇺🇸', 'desc': 'الدولار الأمريكي المعتمد دولياً'},
      {'id': 'CNY', 'label': 'يوان صيني', 'code': 'CNY', 'flag': '🇨🇳', 'desc': 'سعر التكلفة الأصلي في مصانع الصين'},
    ];

    BurhanBottomSheet.show<void>(
      context: context,
      title: 'اختر عملة التسوق والعرض',
      child: Column(
        children: options.map((opt) {
          final isSelected = _selectedCurrency == opt['id'];
          return InkWell(
            onTap: () {
              setState(() => _selectedCurrency = opt['id']!);
              Navigator.pop(context);
              _showToast('تم تغيير العملة إلى ${opt['label']} (${opt['code']})');
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? BurhanColors.slate100 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? BurhanColors.primary : BurhanColors.slate200,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Text(opt['flag']!, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${opt['label']} (${opt['code']})',
                          style: BurhanTypography.titleSmall.copyWith(fontSize: 12),
                        ),
                        Text(
                          opt['desc']!,
                          style: BurhanTypography.caption.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle_rounded, color: BurhanColors.primary, size: 20)
                  else
                    const Icon(Icons.radio_button_unchecked_rounded, color: BurhanColors.slate300, size: 20),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 2. LANGUAGE BOTTOM SHEET
  void _openLanguageSheet() {
    final options = [
      {'id': 'ar', 'label': 'العربية (Arabic)', 'desc': 'واجهة استخدام عربية كاملة من اليمين لليسار'},
      {'id': 'en', 'label': 'English', 'desc': 'English interface and international layout'},
    ];

    BurhanBottomSheet.show<void>(
      context: context,
      title: 'لغة واجهة التطبيق',
      child: Column(
        children: options.map((opt) {
          final isSelected = _selectedLanguage == opt['id'];
          return InkWell(
            onTap: () {
              setState(() => _selectedLanguage = opt['id']!);
              Navigator.pop(context);
              _showToast(opt['id'] == 'ar' ? 'تم اختيار اللغة العربية' : 'English selected');
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? BurhanColors.slate100 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? BurhanColors.primary : BurhanColors.slate200,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(opt['label']!, style: BurhanTypography.titleSmall.copyWith(fontSize: 12)),
                      Text(opt['desc']!, style: BurhanTypography.caption.copyWith(fontSize: 10)),
                    ],
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle_rounded, color: BurhanColors.primary, size: 20)
                  else
                    const Icon(Icons.radio_button_unchecked_rounded, color: BurhanColors.slate300, size: 20),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 3. THEME BOTTOM SHEET
  void _openThemeSheet() {
    final options = [
      {'id': 'light', 'label': 'المظهر الفاتح (Light Mode)', 'icon': Icons.light_mode_outlined, 'desc': 'تصميم ناصع وواضح لمختلف ظروف الإضاءة'},
      {'id': 'dark', 'label': 'المظهر الداكن (Dark Mode)', 'icon': Icons.dark_mode_outlined, 'desc': 'توفير لطاقة البطارية وراحة إضافية للعين'},
      {'id': 'system', 'label': 'تلقائي حسب النظام (System Default)', 'icon': Icons.auto_awesome_rounded, 'desc': 'يتبع الإعداد المفضل لجهازك الذكي'},
    ];

    BurhanBottomSheet.show<void>(
      context: context,
      title: 'مظهر وثيم التطبيق',
      child: Column(
        children: options.map((opt) {
          final isSelected = _selectedTheme == opt['id'];
          final icon = opt['icon'] as IconData;
          return InkWell(
            onTap: () {
              setState(() => _selectedTheme = opt['id'] as String);
              Navigator.pop(context);
              _showToast('تم تطبيق ${opt['label']}');
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? BurhanColors.slate100 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? BurhanColors.primary : BurhanColors.slate200,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: BurhanColors.slate100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 16, color: BurhanColors.slate700),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(opt['label'] as String, style: BurhanTypography.titleSmall.copyWith(fontSize: 12)),
                        Text(opt['desc'] as String, style: BurhanTypography.caption.copyWith(fontSize: 10)),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle_rounded, color: BurhanColors.primary, size: 20)
                  else
                    const Icon(Icons.radio_button_unchecked_rounded, color: BurhanColors.slate300, size: 20),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 4. EDIT PROFILE BOTTOM SHEET
  void _openEditProfileSheet() {
    final nameController = TextEditingController(text: _userName);
    String selectedCity = _userCity;

    BurhanBottomSheet.show<void>(
      context: context,
      title: 'تعديل بيانات الملف الشخصي',
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الاسم الكامل', style: BurhanTypography.bodySmall.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              TextField(
                controller: nameController,
                style: BurhanTypography.bodyMedium,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  filled: true,
                  fillColor: BurhanColors.slate100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: BurhanColors.slate200),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('المدينة في اليمن', style: BurhanTypography.bodySmall.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: BurhanColors.slate100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: BurhanColors.slate200),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCity,
                    isExpanded: true,
                    items: ['صنعاء', 'عدن', 'تعز', 'المكلا', 'إب', 'الحديدة', 'سيئون', 'مأرب']
                        .map((city) => DropdownMenuItem(value: city, child: Text(city, style: BurhanTypography.bodyMedium)))
                        .toList(),
                    onChanged: (val) => setSheetState(() => selectedCity = val ?? selectedCity),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BurhanColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    setState(() {
                      _userName = nameController.text.trim().isEmpty ? _userName : nameController.text.trim();
                      _userCity = selectedCity;
                    });
                    Navigator.pop(context);
                    _showToast('تم تحديث بيانات الملف الشخصي بنجاح');
                  },
                  child: Text('حفظ التعديلات', style: BurhanTypography.titleSmall.copyWith(color: Colors.white)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // 5. CUSTOMER SUPPORT BOTTOM SHEET
  void _openSupportSheet() {
    BurhanBottomSheet.show<void>(
      context: context,
      title: 'خدمة العملاء والدعم الفني',
      child: Column(
        children: [
          Text(
            'فريق دعم منصة برهان متواجد على مدار الساعة في اليمن ومستودع قوانغتشو للإجابة على استفساراتكم ومتابعة شحناتكم.',
            style: BurhanTypography.bodySmall.copyWith(height: 1.4),
          ),
          const SizedBox(height: 14),
          _buildSupportTile(
            title: 'محادثة واتساب الفورية',
            subtitle: 'رد فوري من ممثلي خدمة العملاء',
            icon: Icons.chat_rounded,
            iconColor: Colors.white,
            bgColor: BurhanColors.emerald500,
            onTap: () {
              Navigator.pop(context);
              _showToast('جاري فتح محادثة الدعم عبر واتساب...');
            },
          ),
          const SizedBox(height: 8),
          _buildSupportTile(
            title: 'قناة ومجتمع تيليجرام',
            subtitle: 'تحديثات الشحن ومواعيد مغادرة الرحلات',
            icon: Icons.send_rounded,
            iconColor: Colors.white,
            bgColor: const Color(0xFF0284C7),
            onTap: () {
              Navigator.pop(context);
              _showToast('جاري فتح مجتمع تيليجرام...');
            },
          ),
          const SizedBox(height: 8),
          _buildSupportTile(
            title: 'رقم الاتصال الموحد',
            subtitle: '+967 1 234567 (طوال أيام الأسبوع)',
            icon: Icons.phone_in_talk_rounded,
            iconColor: Colors.white,
            bgColor: BurhanColors.primary,
            onTap: () {
              Navigator.pop(context);
              _showToast('الاتصال بالرقم الموحد: +967 1 234567');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupportTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: BurhanColors.slate100.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: BurhanColors.slate200),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: BurhanTypography.titleSmall.copyWith(fontSize: 12)),
                  Text(subtitle, style: BurhanTypography.caption.copyWith(fontSize: 10)),
                ],
              ),
            ),
            const Icon(Icons.arrow_back_ios_new_rounded, size: 13, color: BurhanColors.slate400),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BurhanColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 10, left: 14, right: 14, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. User Profile Glass Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: BurhanColors.slate200, width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Avatar
                      Stack(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [BurhanColors.primary, BurhanColors.primaryLight],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                'ب',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w900,
                                  color: BurhanColors.amber,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -1,
                            right: -1,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: BurhanColors.emerald500,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),

                      // User Details
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _userName,
                                style: BurhanTypography.titleSmall.copyWith(fontSize: 13),
                              ),
                              const SizedBox(width: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: BurhanColors.amber.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: BurhanColors.amber.withValues(alpha: 0.3),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  'موثق',
                                  style: BurhanTypography.badge.copyWith(
                                    color: BurhanColors.amberDark,
                                    fontSize: 8.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            '+967 770000000',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10.5,
                              color: BurhanColors.slate500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 11, color: BurhanColors.amber),
                              const SizedBox(width: 2),
                              Text(
                                'اليمن - $_userCity',
                                style: BurhanTypography.caption.copyWith(fontSize: 10),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Edit Profile Button
                  InkWell(
                    onTap: _openEditProfileSheet,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: BurhanColors.slate100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: BurhanColors.slate200),
                      ),
                      child: const Icon(Icons.edit_outlined, size: 15, color: BurhanColors.slate700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // SECTION 1: نشاطي ومشترياتي
            _buildSectionHeader('المشتريات والنشاط'),
            const SizedBox(height: 6),
            _buildCardGroup([
              ProfileMenuTile(
                title: 'سجل طلباتي',
                subtitle: 'متابعة مسار الشحنات ومراحل التوصيل',
                icon: Icons.inventory_2_outlined,
                iconColor: BurhanColors.blue500,
                iconBgColor: BurhanColors.blue50,
                badgeText: '3 طلبات',
                badgeColor: BurhanColors.blue50,
                badgeTextColor: BurhanColors.blue500,
                onTap: () => _showToast('الانتقال إلى سجل الطلبات'),
              ),
              ProfileMenuTile(
                title: 'سلة التسوق والشراء الجزئي',
                subtitle: 'إدارة المنتجات وتحديد ما تريد شراءه',
                icon: Icons.shopping_bag_outlined,
                iconColor: BurhanColors.amberDark,
                iconBgColor: BurhanColors.store1688Bg,
                badgeText: '2 عناصر',
                badgeColor: BurhanColors.store1688Bg,
                badgeTextColor: BurhanColors.amberDark,
                onTap: () => _showToast('الانتقال إلى السلة'),
              ),
              ProfileMenuTile(
                title: 'المنتجات المفضلة',
                subtitle: 'المنتجات المحفوظة للطلب لاحقاً',
                icon: Icons.favorite_border_rounded,
                iconColor: BurhanColors.rose500,
                iconBgColor: BurhanColors.rose50,
                badgeText: '4 منتجات',
                badgeColor: BurhanColors.rose50,
                badgeTextColor: BurhanColors.rose500,
                onTap: () => _showToast('الانتقال إلى المفضلة'),
              ),
              ProfileMenuTile(
                title: 'عناوين التوصيل المسجلة',
                subtitle: 'إدارة مواقع الاستلام في محافظات اليمن',
                icon: Icons.location_on_outlined,
                iconColor: BurhanColors.emerald600,
                iconBgColor: BurhanColors.emerald50,
                onTap: () => _showToast('العنوان الافتراضي: صنعاء - شارع حدة'),
              ),
            ]),
            const SizedBox(height: 16),

            // SECTION 2: إعدادات التطبيق والمظهر
            _buildSectionHeader('إعدادات التطبيق والمظهر'),
            const SizedBox(height: 6),
            _buildCardGroup([
              ProfileMenuTile(
                title: 'العملة المعروضة',
                subtitle: 'تحويل فوري لأسعار المصانع الصينية',
                icon: Icons.credit_card_outlined,
                iconColor: BurhanColors.slate700,
                iconBgColor: BurhanColors.slate100,
                badgeText: _selectedCurrency == 'YER'
                    ? '🇾🇪 YER'
                    : _selectedCurrency == 'SAR'
                        ? '🇸🇦 SAR'
                        : _selectedCurrency == 'USD'
                            ? '🇺🇸 USD'
                            : '🇨🇳 CNY',
                onTap: _openCurrencySheet,
              ),
              ProfileMenuTile(
                title: 'لغة التطبيق',
                subtitle: 'واجهة المستخدم واتجاه العرض',
                icon: Icons.language_rounded,
                iconColor: BurhanColors.slate700,
                iconBgColor: BurhanColors.slate100,
                badgeText: _selectedLanguage == 'ar' ? 'العربية' : 'English',
                onTap: _openLanguageSheet,
              ),
              ProfileMenuTile(
                title: 'المظهر والثيم',
                subtitle: 'نمط الألوان وراحة العين',
                icon: _selectedTheme == 'dark' ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                iconColor: BurhanColors.slate700,
                iconBgColor: BurhanColors.slate100,
                badgeText: _selectedTheme == 'light'
                    ? 'فاتح'
                    : _selectedTheme == 'dark'
                        ? 'داكن'
                        : 'تلقائي',
                onTap: _openThemeSheet,
              ),
              ProfileMenuTile(
                title: 'إشعارات الشحنات والعروض',
                subtitle: 'تنبيهات حالة الشحن وتصوير الفحص',
                icon: Icons.notifications_none_rounded,
                iconColor: BurhanColors.slate700,
                iconBgColor: BurhanColors.slate100,
                trailing: Switch(
                  value: _notificationsEnabled,
                  activeThumbColor: BurhanColors.primary,
                  onChanged: (val) {
                    setState(() => _notificationsEnabled = val);
                    _showToast(val ? 'تم تفعيل إشعارات الشحن' : 'تم كتم إشعارات التطبيق مؤقتاً');
                  },
                ),
              ),
            ]),
            const SizedBox(height: 16),

            // SECTION 3: الدعم والضمانات
            _buildSectionHeader('الدعم والضمانات'),
            const SizedBox(height: 6),
            _buildCardGroup([
              ProfileMenuTile(
                title: 'دليل عمل منصة برهان',
                subtitle: 'خطوات الشراء، الفحص، والشحن لبابك',
                icon: Icons.help_outline_rounded,
                iconColor: BurhanColors.amberDark,
                iconBgColor: BurhanColors.store1688Bg,
                onTap: () => _showToast('دليل المنصة: 1. الطلب 2. الفحص بقوانغتشو 3. الشحن لليمن'),
              ),
              ProfileMenuTile(
                title: 'خدمة العملاء والمساعدة',
                subtitle: 'فريق الدعم المباشر عبر واتساب وتيليجرام',
                icon: Icons.support_agent_rounded,
                iconColor: BurhanColors.blue500,
                iconBgColor: BurhanColors.blue50,
                onTap: _openSupportSheet,
              ),
              ProfileMenuTile(
                title: 'الضمانات وسياسة الاسترجاع',
                subtitle: 'فحص عيني 100% واسترداد عند عدم المطابقة',
                icon: Icons.verified_user_outlined,
                iconColor: BurhanColors.emerald600,
                iconBgColor: BurhanColors.emerald50,
                onTap: () => _showToast('ضمان برهان: فحص كامل للمواصفات واسترداد مضمون'),
              ),
            ]),
            const SizedBox(height: 16),

            // SECTION 4: إدارة الحساب والأمان
            _buildSectionHeader('إدارة الحساب والأمان'),
            const SizedBox(height: 6),
            _buildCardGroup([
              ProfileMenuTile(
                title: 'تسجيل الخروج',
                subtitle: 'الخروج من هذا الجهاز أو التبديل لحساب آخر',
                icon: Icons.logout_rounded,
                iconColor: BurhanColors.amberDark,
                iconBgColor: BurhanColors.store1688Bg,
                onTap: () => _showToast('تم تسجيل الخروج بنجاح'),
              ),
              ProfileMenuTile(
                title: 'حذف الحساب نهائياً',
                subtitle: 'مسح كافة البيانات وسجل الطلبات من الخوادم',
                icon: Icons.delete_outline_rounded,
                iconColor: BurhanColors.rose500,
                iconBgColor: BurhanColors.rose50,
                isDestructive: true,
                onTap: () => _showToast('إجراء أمني: يتطلب تأكيد حذف الحساب'),
              ),
            ]),
            const SizedBox(height: 24),

            // App Version Footer
            Center(
              child: Column(
                children: [
                  Text(
                    'منصة برهان (Burhan) · الإصدار 2.4.0',
                    style: BurhanTypography.caption.copyWith(
                      color: BurhanColors.slate400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'بوابتك الموثوقة للشراء المباشر من مصانع الصين',
                    style: BurhanTypography.caption.copyWith(
                      color: BurhanColors.slate400,
                      fontSize: 9.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: BurhanTypography.caption.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: BurhanColors.slate500,
        ),
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BurhanColors.slate200, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: children.length,
        separatorBuilder: (_, _) => const Divider(
          color: BurhanColors.slate100,
          height: 1,
          thickness: 1,
        ),
        itemBuilder: (_, index) => children[index],
      ),
    );
  }
}
