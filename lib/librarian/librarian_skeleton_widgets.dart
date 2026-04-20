import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LibrarianSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsets? margin;

  const LibrarianSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = 8,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              // Header Card Skeleton
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(context.lg),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(context.scale(24)),
                ),
                child: context.isMobile
                    ? Column(
                        children: [
                          LibrarianSkeleton(width: context.scale(110), height: context.scale(110), borderRadius: context.scale(55)),
                          SizedBox(height: context.md),
                          LibrarianSkeleton(width: context.scale(150), height: context.scale(24)),
                          SizedBox(height: context.xs),
                          LibrarianSkeleton(width: context.scale(200), height: context.scale(16)),
                        ],
                      )
                    : Row(
                        children: [
                          LibrarianSkeleton(width: context.scale(110), height: context.scale(110), borderRadius: context.scale(55)),
                          SizedBox(width: context.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LibrarianSkeleton(width: context.scale(200), height: context.scale(24)),
                                SizedBox(height: context.xs),
                                LibrarianSkeleton(width: context.scale(250), height: context.scale(16)),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
              SizedBox(height: context.lg),
              // Sections
              for (int i = 0; i < 4; i++) ...[
                _buildSectionSkeleton(context),
                SizedBox(height: context.md),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionSkeleton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(context.scale(16)),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const LibrarianSkeleton(width: 24, height: 24),
              SizedBox(width: context.sm),
              const LibrarianSkeleton(width: 150, height: 20),
            ],
          ),
          SizedBox(height: context.md),
          Row(
            children: [
              const Expanded(child: LibrarianSkeleton(height: 50)),
              SizedBox(width: context.sm),
              const Expanded(child: LibrarianSkeleton(height: 50)),
            ],
          ),
          SizedBox(height: context.sm),
          Row(
            children: [
              const Expanded(child: LibrarianSkeleton(height: 50)),
              SizedBox(width: context.sm),
              const Expanded(child: LibrarianSkeleton(height: 50)),
            ],
          ),
        ],
      ),
    );
  }
}

class SalarySkeleton extends StatelessWidget {
  const SalarySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bank Card Skeleton
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(context.lg),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(context.scale(28)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        LibrarianSkeleton(width: context.scale(30), height: context.scale(30), borderRadius: 15),
                        SizedBox(width: context.md),
                        const LibrarianSkeleton(width: 120, height: 24),
                      ],
                    ),
                    SizedBox(height: context.lg),
                    for (int i = 0; i < 5; i++) ...[
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          LibrarianSkeleton(width: 100, height: 16),
                          LibrarianSkeleton(width: 140, height: 16),
                        ],
                      ),
                      SizedBox(height: context.md),
                      if (i < 4) Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
                      if (i < 4) SizedBox(height: context.md),
                    ],
                  ],
                ),
              ),
              SizedBox(height: context.xl),
              // History Title
              const LibrarianSkeleton(width: 180, height: 22),
              SizedBox(height: context.md),
              // Salary List Skeletons
              for (int i = 0; i < 4; i++) ...[
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: context.md),
                  padding: EdgeInsets.all(context.md),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(context.scale(20)),
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      LibrarianSkeleton(width: context.scale(40), height: context.scale(40), borderRadius: 12),
                      SizedBox(width: context.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const LibrarianSkeleton(width: 80, height: 20),
                            SizedBox(height: context.xs),
                            const LibrarianSkeleton(width: 120, height: 14),
                          ],
                        ),
                      ),
                      const LibrarianSkeleton(width: 70, height: 24, borderRadius: 10),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class TicketSkeleton extends StatelessWidget {
  const TicketSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Section Skeleton
          Container(
            padding: EdgeInsets.all(context.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(context.scale(20)),
            ),
            child: Column(
              children: [
                const LibrarianSkeleton(height: 50, borderRadius: 12),
                SizedBox(height: context.sm),
                const Row(
                  children: [
                    Expanded(child: LibrarianSkeleton(height: 50, borderRadius: 12)),
                    SizedBox(width: 12),
                    Expanded(child: LibrarianSkeleton(height: 50, borderRadius: 12)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: context.md),
          // Table Section Skeleton
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(context.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(context.scale(20)),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LibrarianSkeleton(width: 150, height: 24),
                SizedBox(height: context.lg),
                for (int i = 0; i < 6; i++) ...[
                  const LibrarianSkeleton(height: 60, borderRadius: 8),
                  SizedBox(height: context.sm),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EditIssueSkeleton extends StatelessWidget {
  const EditIssueSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.scale(24)),
                  side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(context.lg),
                  child: Column(
                    children: [
                      Center(
                        child: Column(
                          children: [
                            LibrarianSkeleton(width: context.scale(64), height: context.scale(64), borderRadius: 20),
                            SizedBox(height: context.md),
                            const LibrarianSkeleton(width: 180, height: 24),
                            SizedBox(height: context.xs),
                            const LibrarianSkeleton(width: 240, height: 16),
                          ],
                        ),
                      ),
                      SizedBox(height: context.lg),
                      const Row(
                        children: [
                          Expanded(child: LibrarianSkeleton(height: 80, borderRadius: 16)),
                          SizedBox(width: 12),
                          Expanded(child: LibrarianSkeleton(height: 80, borderRadius: 16)),
                        ],
                      ),
                      SizedBox(height: context.md),
                      const Row(
                        children: [
                          Expanded(child: LibrarianSkeleton(height: 80, borderRadius: 16)),
                          SizedBox(width: 12),
                          Expanded(child: LibrarianSkeleton(height: 80, borderRadius: 16)),
                        ],
                      ),
                      SizedBox(height: context.md),
                      const LibrarianSkeleton(height: 120, borderRadius: 16),
                      SizedBox(height: context.lg),
                      const LibrarianSkeleton(height: 50, borderRadius: 12),
                      SizedBox(height: context.md),
                      const LibrarianSkeleton(height: 50, borderRadius: 12),
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
}

class TableSkeleton extends StatelessWidget {
  final int rows;
  const TableSkeleton({super.key, this.rows = 6});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // Filter Card Skeleton
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(context.lg),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(context.scale(20)),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        LibrarianSkeleton(width: 20, height: 20),
                        SizedBox(width: 12),
                        LibrarianSkeleton(width: 150, height: 20),
                      ],
                    ),
                    SizedBox(height: context.md),
                    const Row(
                      children: [
                        Expanded(child: LibrarianSkeleton(height: 50, borderRadius: 12)),
                        SizedBox(width: 12),
                        Expanded(child: LibrarianSkeleton(height: 50, borderRadius: 12)),
                      ],
                    ),
                    SizedBox(height: context.sm),
                    const Row(
                      children: [
                        Expanded(child: LibrarianSkeleton(height: 50, borderRadius: 12)),
                        SizedBox(width: 12),
                        Expanded(child: LibrarianSkeleton(height: 50, borderRadius: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.lg),
              // Table Card Skeleton
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(context.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(context.scale(20)),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    const LibrarianSkeleton(height: 50, borderRadius: 12),
                    SizedBox(height: context.lg),
                    for (int i = 0; i < rows; i++) ...[
                      const LibrarianSkeleton(height: 60, borderRadius: 8),
                      SizedBox(height: context.sm),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GridSkeleton extends StatelessWidget {
  const GridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const LibrarianSkeleton(height: 150, borderRadius: 20),
              SizedBox(height: context.lg),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: context.responsive<int>(1, tablet: 2, desktop: 3),
                  mainAxisExtent: context.scale(260),
                  crossAxisSpacing: context.md,
                  mainAxisSpacing: context.md,
                ),
                itemCount: 6,
                itemBuilder: (context, index) => const LibrarianSkeleton(height: 260, borderRadius: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
