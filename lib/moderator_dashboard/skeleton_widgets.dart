import 'package:eduphin/services/error_handler.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';

class ModeratorLoadingWrapper<T> extends StatelessWidget {
  final AsyncSnapshot<T> snapshot;
  final T? cachedData;
  final Widget skeleton;
  final Widget Function(T data) builder;
  final VoidCallback? onRefresh;

  const ModeratorLoadingWrapper({
    super.key,
    required this.snapshot,
    this.cachedData,
    required this.skeleton,
    required this.builder,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (snapshot.hasData) {
      return builder(snapshot.data as T);
    } else if (snapshot.hasError) {
      if (cachedData != null) {
        return builder(cachedData as T);
      }
      return Center(
        child: Padding(
          padding: context.pagePadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  color: theme.colorScheme.error, size: context.scale(48)),
              SizedBox(height: context.scale(16)),
              Text(
                ErrorHandler.getMessage(snapshot.error),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.hintColor,
                  fontSize: context.font(14),
                ),
              ),
              if (onRefresh != null) ...[
                SizedBox(height: context.scale(24)),
                FilledButton.tonal(
                  onPressed: onRefresh,
                  child: const Text('Try Again'),
                ),
              ],
            ],
          ),
        ),
      );
    } else if (snapshot.connectionState == ConnectionState.waiting) {
      if (cachedData != null) {
        return builder(cachedData as T);
      }
      return skeleton;
    } else {
      if (cachedData != null) {
        return builder(cachedData as T);
      }
      return const Center(child: Text('No data available'));
    }
  }
}

class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ReviewSkeleton extends StatelessWidget {
  const ReviewSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Column(
        children: List.generate(
          6,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: context.spacing),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(context.spacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SkeletonBox(width: context.scale(48), height: context.scale(48), borderRadius: context.scale(24)),
                        SizedBox(width: context.spacing),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonBox(width: context.scale(100), height: context.scale(16)),
                            SizedBox(height: context.scale(4)),
                            SkeletonBox(width: context.scale(150), height: context.scale(12)),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: context.spacing),
                    const Divider(),
                    SizedBox(height: context.spacing / 2),
                    SkeletonBox(width: double.infinity, height: context.scale(14)),
                    SizedBox(height: context.scale(4)),
                    SkeletonBox(width: double.infinity, height: context.scale(14)),
                    SizedBox(height: context.scale(4)),
                    SkeletonBox(width: context.scale(200), height: context.scale(14)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NotificationSkeleton extends StatelessWidget {
  const NotificationSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: context.pagePadding,
      itemCount: 8,
      itemBuilder: (context, index) => Card(
        margin: EdgeInsets.only(bottom: context.scale(16)),
        child: Padding(
          padding: EdgeInsets.all(context.scale(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SkeletonBox(width: context.scale(48), height: context.scale(48), borderRadius: context.scale(24)),
                  SizedBox(width: context.scale(16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: context.scale(120), height: context.scale(16)),
                        SizedBox(height: context.scale(8)),
                        SkeletonBox(width: context.scale(180), height: context.scale(12)),
                      ],
                    ),
                  ),
                  SizedBox(width: context.scale(8)),
                  SkeletonBox(width: context.scale(40), height: context.scale(10)),
                ],
              ),
              SizedBox(height: context.scale(12)),
              const Divider(height: 1),
              SizedBox(height: context.scale(12)),
              SkeletonBox(width: double.infinity, height: context.scale(14)),
              SizedBox(height: context.scale(6)),
              SkeletonBox(width: context.scale(200), height: context.scale(14)),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Column(
        children: [
          SkeletonBox(width: double.infinity, height: context.scale(150), borderRadius: context.scale(24)),
          SizedBox(height: context.scale(32)),
          ...List.generate(3, (index) => Column(
            children: [
              SkeletonBox(width: double.infinity, height: context.scale(200), borderRadius: context.scale(12)),
              SizedBox(height: context.scale(16)),
            ],
          )),
        ],
      ),
    );
  }
}

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonBox(width: context.scale(48), height: context.scale(48), borderRadius: context.scale(24)),
              SizedBox(width: context.spacing),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: context.scale(150), height: context.scale(20)),
                  SizedBox(height: context.scale(4)),
                  SkeletonBox(width: context.scale(200), height: context.scale(14)),
                ],
              ),
            ],
          ),
          SizedBox(height: context.spacing),
          SkeletonBox(width: double.infinity, height: context.scale(48), borderRadius: context.scale(30)),
          SizedBox(height: context.spacing),
          Row(
            children: [
              Expanded(child: SkeletonBox(width: double.infinity, height: context.scale(44), borderRadius: context.scale(22))),
              SizedBox(width: context.spacing / 2),
              Expanded(child: SkeletonBox(width: double.infinity, height: context.scale(44), borderRadius: context.scale(22))),
            ],
          ),
          SizedBox(height: context.spacing),
          SkeletonBox(width: context.scale(150), height: context.scale(24)),
          SizedBox(height: context.scale(12)),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: context.spacing / 2,
              mainAxisSpacing: context.spacing / 2,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, index) => SkeletonBox(width: double.infinity, height: context.scale(100)),
          ),
        ],
      ),
    );
  }
}

class TestimonialSkeleton extends StatelessWidget {
  const TestimonialSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: context.scale(200), height: context.scale(28)),
          SizedBox(height: context.scale(8)),
          SkeletonBox(width: context.scale(250), height: context.scale(16)),
          SizedBox(height: context.scale(24)),
          ...List.generate(3, (index) => Padding(
            padding: EdgeInsets.only(bottom: context.scale(16)),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(context.scale(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: context.scale(32), height: context.scale(32)),
                    SizedBox(height: context.scale(16)),
                    SkeletonBox(width: double.infinity, height: context.scale(16)),
                    SizedBox(height: context.scale(8)),
                    SkeletonBox(width: double.infinity, height: context.scale(16)),
                    SizedBox(height: context.scale(8)),
                    SkeletonBox(width: context.scale(150), height: context.scale(16)),
                    SizedBox(height: context.scale(24)),
                    Row(
                      children: [
                        SkeletonBox(width: context.scale(40), height: context.scale(40), borderRadius: context.scale(20)),
                        SizedBox(width: context.scale(12)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonBox(width: context.scale(100), height: context.scale(14)),
                            SizedBox(height: context.scale(4)),
                            SkeletonBox(width: context.scale(120), height: context.scale(12)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}

class RoleDistributionSkeleton extends StatelessWidget {
  const RoleDistributionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Column(
        children: [
          SkeletonBox(width: double.infinity, height: context.scale(140), borderRadius: context.scale(16)),
          SizedBox(height: context.scale(24)),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
              crossAxisSpacing: context.md,
              mainAxisSpacing: context.md,
              mainAxisExtent: context.scale(140),
            ),
            itemBuilder: (context, index) => SkeletonBox(width: double.infinity, height: context.scale(140), borderRadius: context.scale(12)),
          ),
        ],
      ),
    );
  }
}

class ListSkeleton extends StatelessWidget {
  const ListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: context.pagePadding,
      itemCount: 10,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: context.md),
        child: SkeletonBox(width: double.infinity, height: context.scale(80), borderRadius: context.scale(12)),
      ),
    );
  }
}

class InstituteSkeleton extends StatelessWidget {
  const InstituteSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: SkeletonBox(width: double.infinity, height: context.scale(48), borderRadius: context.scale(12))),
              SizedBox(width: context.md),
              SkeletonBox(width: context.scale(48), height: context.scale(48), borderRadius: context.scale(12)),
            ],
          ),
          SizedBox(height: context.md),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
              crossAxisSpacing: context.md,
              mainAxisSpacing: context.md,
              mainAxisExtent: context.scale(210),
            ),
            itemBuilder: (context, index) => SkeletonBox(width: double.infinity, height: context.scale(210), borderRadius: context.scale(20)),
          ),
        ],
      ),
    );
  }
}

class DetailSkeleton extends StatelessWidget {
  const DetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Column(
        children: [
          Center(child: SkeletonBox(width: context.scale(120), height: context.scale(120), borderRadius: context.scale(60))),
          SizedBox(height: context.md),
          Center(child: SkeletonBox(width: context.scale(200), height: context.scale(24))),
          SizedBox(height: context.sm),
          Center(child: SkeletonBox(width: context.scale(100), height: context.scale(16))),
          SizedBox(height: context.lg),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 8,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: context.responsive(1, tablet: 2),
              crossAxisSpacing: context.md,
              mainAxisSpacing: context.md,
              mainAxisExtent: context.scale(100),
            ),
            itemBuilder: (context, index) => SkeletonBox(width: double.infinity, height: context.scale(100), borderRadius: context.scale(16)),
          ),
        ],
      ),
    );
  }
}
