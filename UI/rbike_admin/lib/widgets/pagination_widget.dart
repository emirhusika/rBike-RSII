import 'package:flutter/material.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalCount;
  final int pageSize;
  final Function(int) onPageChanged;
  final bool isLoading;

  const PaginationWidget({
    Key? key,
    required this.currentPage,
    required this.totalCount,
    required this.pageSize,
    required this.onPageChanged,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalPages = (totalCount / pageSize).ceil();

    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous page button
          _buildPageButton(
            onPressed:
                currentPage > 1 && !isLoading
                    ? () => onPageChanged(currentPage - 1)
                    : null,
            icon: Icons.arrow_back_ios,
            label: "Prethodna",
            isEnabled: currentPage > 1 && !isLoading,
          ),

          const SizedBox(width: 24),

          // Page info - simplified
          Text(
            "Stranica $currentPage od $totalPages",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),

          const SizedBox(width: 24),

          // Next page button
          _buildPageButton(
            onPressed:
                currentPage < totalPages && !isLoading
                    ? () => onPageChanged(currentPage + 1)
                    : null,
            icon: Icons.arrow_forward_ios,
            label: "Sljedeća",
            isEnabled: currentPage < totalPages && !isLoading,
            isNext: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPageButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required bool isEnabled,
    bool isNext = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient:
            isEnabled
                ? LinearGradient(
                  colors:
                      isNext
                          ? [Colors.green.shade400, Colors.green.shade600]
                          : [Colors.blue.shade400, Colors.blue.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                : null,
        color: isEnabled ? null : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
        boxShadow:
            isEnabled
                ? [
                  BoxShadow(
                    color: (isNext ? Colors.green : Colors.blue).withOpacity(
                      0.3,
                    ),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Icon(
              icon,
              size: 18,
              color: isEnabled ? Colors.white : Colors.grey.shade500,
            ),
          ),
        ),
      ),
    );
  }
}

// Alternative pagination widget with icon buttons (like in equipment_list_screen)
class IconPaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalCount;
  final int pageSize;
  final Function(int) onPageChanged;
  final bool isLoading;

  const IconPaginationWidget({
    Key? key,
    required this.currentPage,
    required this.totalCount,
    required this.pageSize,
    required this.onPageChanged,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalPages = (totalCount / pageSize).ceil();

    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous page icon button
          _buildIconButton(
            onPressed:
                currentPage > 1 && !isLoading
                    ? () => onPageChanged(currentPage - 1)
                    : null,
            icon: Icons.arrow_back_ios,
            isEnabled: currentPage > 1 && !isLoading,
          ),

          const SizedBox(width: 20),

          // Page info - simplified
          Text(
            'Stranica $currentPage od $totalPages',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),

          const SizedBox(width: 20),

          // Next page icon button
          _buildIconButton(
            onPressed:
                currentPage < totalPages && !isLoading
                    ? () => onPageChanged(currentPage + 1)
                    : null,
            icon: Icons.arrow_forward_ios,
            isEnabled: currentPage < totalPages && !isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required bool isEnabled,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient:
            isEnabled
                ? LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                : null,
        color: isEnabled ? null : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
        boxShadow:
            isEnabled
                ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              size: 20,
              color: isEnabled ? Colors.white : Colors.grey.shade500,
            ),
          ),
        ),
      ),
    );
  }
}
