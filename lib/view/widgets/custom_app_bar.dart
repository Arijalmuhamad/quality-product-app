import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onHome;
  final VoidCallback? onRefresh;
  final String title;
  final bool showBackButton; // <- Tambahan

  const CustomAppBar({
    Key? key,
    this.onHome,
    this.onRefresh,
    required this.title,
    this.showBackButton = false, // <- Default false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleSpacing: 16,
      automaticallyImplyLeading: false,
      leading:
          showBackButton
              ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              )
              : null,
      title: Row(
        children: [
          Image.asset('assets/images/logo-kpn-1.png', width: 30),
          const SizedBox(width: 10),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        if (onHome != null)
          ElevatedButton(
            onPressed: onHome,
            child: const Icon(Icons.home, color: Colors.blue, size: 40),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(0),
              ),
            ),
          ),
        if (onRefresh != null)
          ElevatedButton(
            onPressed: onRefresh,
            child: const Icon(Icons.refresh, color: Colors.green, size: 40),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(0),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
