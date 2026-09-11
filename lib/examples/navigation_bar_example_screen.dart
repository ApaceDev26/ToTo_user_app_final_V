import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toto_user/helper/system_ui_helper.dart';

/// Example screen demonstrating Android navigation bar customization.
///
/// This example shows:
/// 1. How to wrap a Scaffold with AnnotatedRegion for navigation bar styling
/// 2. How to use different colors for light/dark backgrounds
/// 3. How to automatically calculate icon brightness
/// 4. How to manually set icon brightness
/// 5. Per-screen customization vs app-wide styling
class NavigationBarExampleScreen extends StatefulWidget {
  const NavigationBarExampleScreen({super.key});

  @override
  State<NavigationBarExampleScreen> createState() =>
      _NavigationBarExampleScreenState();
}

class _NavigationBarExampleScreenState
    extends State<NavigationBarExampleScreen> {
  Color _selectedColor = Colors.blue;
  Brightness? _selectedBrightness; // null = auto-calculate

  // Example colors to choose from
  final List<Color> _colorOptions = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.black,
    Colors.white,
    const Color(0xFF1E1E1E), // Dark gray
    const Color(0xFF2E7D32), // Material Green 800
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine icon brightness - auto-calculate if not manually set
    final Brightness iconBrightness = _selectedBrightness ??
        SystemUIHelper.getIconBrightnessForColor(_selectedColor);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Method 1: Using SystemUIHelper helper (recommended)
      value: SystemUIHelper.getNavigationBarStyle(
        navigationBarColor: _selectedColor,
        iconBrightness: iconBrightness,
        // Optional: Also customize status bar
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      // Alternative Method 2: Direct SystemUiOverlayStyle (manual)
      // value: SystemUiOverlayStyle(
      //   systemNavigationBarColor: _selectedColor,
      //   systemNavigationBarIconBrightness: iconBrightness,
      //   systemNavigationBarDividerColor: Colors.transparent,
      //   statusBarColor: Colors.transparent,
      // ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Navigation Bar Example'),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Android Navigation Bar Styling',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Current Color: ${_selectedColor.value.toRadixString(16).toUpperCase()}',
                        style: TextStyle(
                          color: _selectedColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Icon Brightness: ${iconBrightness == Brightness.light ? "Light Icons (for dark backgrounds)" : "Dark Icons (for light backgrounds)"}',
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Note: This only affects Android devices. iOS navigation is handled by the OS.',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Color Selection
              const Text(
                'Select Navigation Bar Color:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _colorOptions.map((color) {
                  final bool isSelected = color == _selectedColor;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                        // Reset to auto-calculate when color changes
                        _selectedBrightness = null;
                      });
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey,
                          width: isSelected ? 4 : 1,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Manual Brightness Override
              const Text(
                'Icon Brightness (Optional Override):',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SegmentedButton<Brightness?>(
                segments: const [
                  ButtonSegment<Brightness?>(
                    value: null,
                    label: Text('Auto'),
                  ),
                  ButtonSegment<Brightness?>(
                    value: Brightness.light,
                    label: Text('Light'),
                  ),
                  ButtonSegment<Brightness?>(
                    value: Brightness.dark,
                    label: Text('Dark'),
                  ),
                ],
                selected: {_selectedBrightness},
                onSelectionChanged: (Set<Brightness?> newSelection) {
                  setState(() {
                    _selectedBrightness = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Code Example Card
              Card(
                color: Theme.of(context).cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Code Example:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        '''
// Method 1: Using SystemUIHelper (Recommended)
AnnotatedRegion<SystemUiOverlayStyle>(
  value: SystemUIHelper.getNavigationBarStyle(
    navigationBarColor: Colors.blue,
    iconBrightness: Brightness.light, // or null for auto
  ),
  child: Scaffold(
    appBar: AppBar(title: Text('Example')),
    body: YourContent(),
  ),
)

// Method 2: Direct SystemUIOverlayStyle
AnnotatedRegion<SystemUiOverlayStyle>(
  value: SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.blue,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarDividerColor: Colors.transparent,
  ),
  child: Scaffold(...),
)
''',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Tips Card
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Tips for Android 10+:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTip(
                          '• Use AnnotatedRegion for per-screen customization'),
                      _buildTip(
                          '• Icon brightness is automatically calculated based on color luminance'),
                      _buildTip(
                          '• Dark backgrounds (low luminance) = Light icons'),
                      _buildTip(
                          '• Light backgrounds (high luminance) = Dark icons'),
                      _buildTip(
                          '• For fullscreen/immersive mode, ensure extendBodyBehindAppBar is set correctly'),
                      _buildTip(
                          '• Navigation bar color won\'t affect iOS devices'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text),
    );
  }
}

/// Alternative: Simple example with a fixed color
/// This is the minimal implementation for a single screen
class SimpleNavigationBarExample extends StatelessWidget {
  const SimpleNavigationBarExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Define your navigation bar color
    const Color navBarColor = Colors.blue;

    // Icon brightness will be auto-calculated
    final Brightness iconBrightness =
        SystemUIHelper.getIconBrightnessForColor(navBarColor);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUIHelper.getNavigationBarStyle(
        navigationBarColor: navBarColor,
        iconBrightness: iconBrightness,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Simple Example'),
        ),
        body: const Center(
          child: Text(
            'This Scaffold has a blue navigation bar with automatically '
            'calculated icon brightness.\n\n'
            'On Android 10+, the navigation bar will be blue.\n'
            'On iOS, this has no effect.',
          ),
        ),
      ),
    );
  }
}

/// Example with theme-aware colors
/// This adapts to light/dark theme automatically
class ThemeAwareNavigationBarExample extends StatelessWidget {
  const ThemeAwareNavigationBarExample({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Get navigation bar color based on theme
    final Color navBarColor = SystemUIHelper.getNavigationBarColorForTheme(
      isDarkTheme: isDark,
      // Optional: override defaults
      // lightColor: Colors.white,
      // darkColor: const Color(0xFF1E1E1E),
    );

    return SystemUIHelper.wrapWithSystemUI(
      navigationBarColor: navBarColor,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Theme-Aware Example'),
        ),
        body: Center(
          child: Text(
            'Navigation bar color adapts to your theme:\n'
            'Light theme: White\n'
            'Dark theme: Dark gray\n\n'
            'Icon brightness is automatically calculated.',
          ),
        ),
      ),
    );
  }
}
