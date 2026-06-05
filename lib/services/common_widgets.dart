import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final dynamic borderRadius;

  const SkeletonBox({super.key, this.width, this.height, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surfaceContainerHighest,
      highlightColor: theme.colorScheme.surface,
      child: Container(
        width: width ?? double.infinity,
        height: height ?? context.scale(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: borderRadius is BorderRadius
              ? borderRadius
              : BorderRadius.circular((borderRadius as num?)?.toDouble() ?? context.scale(8)),
        ),
      ),
    );
  }
}

class Skeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final dynamic borderRadius;

  const Skeleton({super.key, this.width, this.height, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surfaceContainerHighest,
      highlightColor: theme.colorScheme.surface,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: borderRadius is BorderRadius 
              ? borderRadius 
              : BorderRadius.circular(borderRadius?.toDouble() ?? context.scale(8)),
        ),
      ),
    );
  }
}

class LoadingWrapper<T> extends StatelessWidget {
  final AsyncSnapshot<T>? snapshot;
  final bool? isLoading;
  final bool? hasData;
  final Object? error;
  final Widget skeleton;
  final Widget? child;
  final Widget Function(T data)? builder;
  final VoidCallback? onRetry;
  final VoidCallback? onRefresh;

  const LoadingWrapper({
    super.key,
    this.snapshot,
    this.isLoading,
    this.hasData,
    this.error,
    required this.skeleton,
    this.child,
    this.builder,
    this.onRetry,
    this.onRefresh,
  }) : assert(snapshot != null || isLoading != null, 'Either snapshot or isLoading must be provided'),
       assert(child != null || builder != null, 'Either child or builder must be provided');

  @override
  Widget build(BuildContext context) {
    bool loading;
    if (isLoading != null) {
      if (hasData != null) {
        loading = isLoading! && !hasData!;
      } else {
        loading = isLoading!;
      }
    } else {
      loading = snapshot!.connectionState == ConnectionState.waiting && !snapshot!.hasData;
    }
    
    if (loading) {
      return skeleton;
    }

    final hasError = error != null || (snapshot != null && snapshot!.hasError && !snapshot!.hasData);
    if (hasError) {
      final theme = context.theme;
      final errorMessage = ErrorHandler.getMessage(error ?? snapshot!.error);
      
      return Center(
        child: Padding(
          padding: context.pagePadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: theme.colorScheme.error, size: context.scale(48)),
              SizedBox(height: context.scale(16)),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.hintColor),
              ),
              if (onRetry != null) ...[
                SizedBox(height: context.scale(24)),
                FilledButton.tonal(onPressed: onRetry, child: const Text("Retry")),
              ],
            ],
          ),
        ),
      );
    }

    Widget content;
    if (child != null) {
      content = child!;
    } else if (builder != null) {
      if (snapshot != null && !snapshot!.hasData) {
        content = const SizedBox.shrink();
      } else {
        content = builder!(snapshot!.data as T);
      }
    } else {
      content = const SizedBox.shrink();
    }

    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: () async => onRefresh!(),
        child: content,
      );
    }

    return content;
  }
}

class SkeletonLoader extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surfaceContainerHighest,
      highlightColor: theme.colorScheme.surface,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: borderRadius ?? BorderRadius.circular(context.scale(8)),
        ),
      ),
    );
  }
}

class ProfileSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final String? status;
  final bool isReadOnly;

  const ProfileSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.status,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.scale(24.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: context.scale(4),
              bottom: context.scale(12),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: context.scale(20),
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: context.scale(8)),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: context.font(16),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (status != null) ...[
                  SizedBox(width: context.scale(8)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.scale(10),
                      vertical: context.scale(4),
                    ),
                    decoration: BoxDecoration(
                      color: isReadOnly
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.05)
                          : theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(context.scale(8)),
                    ),
                    child: Text(
                      status!,
                      style: TextStyle(
                        fontSize: context.font(10),
                        fontWeight: FontWeight.bold,
                        color: isReadOnly
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                            : theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Card(
            child: Padding(
              padding: EdgeInsets.all(context.scale(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdaptiveFieldRow extends StatelessWidget {
  final List<Widget> children;

  const AdaptiveFieldRow({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children
          .map((c) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: children.last == c ? 0 : context.scale(16),
                  ),
                  child: c,
                ),
              ))
          .toList(),
    );
  }
}

class ProfileTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final IconData? icon;
  final bool isPassword;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final bool readOnly;
  final TextInputType? keyboardType;
  final int maxLines;

  final String? errorText;

  const ProfileTextField({
    super.key,
    required this.label,
    required this.controller,
    this.enabled = true,
    this.icon,
    this.isPassword = false,
    this.validator,
    this.onTap,
    this.readOnly = false,
    this.keyboardType,
    this.maxLines = 1,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.scale(16)),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        readOnly: readOnly,
        obscureText: isPassword,
        validator: validator,
        onTap: onTap,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(fontSize: context.font(14)),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, size: context.scale(20)) : null,
          errorText: errorText,
          filled: !enabled || readOnly,
          fillColor: (!enabled || readOnly)
              ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
              : null,
        ),
      ),
    );
  }
}

class ProfileDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final IconData? icon;
  final String? Function(String?)? validator;
  final String? errorText;

  const ProfileDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.icon,
    this.validator,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.scale(16)),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: value,
        style: TextStyle(
          fontSize: context.font(14),
          color: context.theme.colorScheme.onSurface,
        ),
        items: items
            .map((i) => DropdownMenuItem(
                  value: i,
                  child: Text(
                    i,
                    overflow: TextOverflow.ellipsis,
                  ),
                ))
            .toList(),
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, size: context.scale(20)) : null,
          errorText: errorText,
        ),
      ),
    );
  }
}

class InstituteLogo extends StatelessWidget {
  final String? logoUrl;
  final double size;
  final IconData fallbackIcon;
  final Color? fallbackColor;

  const InstituteLogo({
    super.key,
    this.logoUrl,
    required this.size,
    this.fallbackIcon = Icons.school,
    this.fallbackColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final color = fallbackColor ?? theme.colorScheme.primary;

    if (logoUrl == null || logoUrl!.isEmpty || logoUrl == "null") {
      return Icon(fallbackIcon, color: color, size: size);
    }

    final fullUrl = ApiService.getStorageUrl(logoUrl);

    return FutureBuilder<String?>(
      future: ApiService.getToken(),
      builder: (context, snapshot) {
        final bool isStorageUrl = fullUrl.contains('/storage/');
        return Image.network(
          fullUrl,
          width: size,
          height: size,
          fit: BoxFit.contain,
          headers: isStorageUrl ? null : {
            if (snapshot.data != null) 'Authorization': 'Bearer ${snapshot.data}',
            'User-Agent': 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36',
            'Accept': 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
          },
          errorBuilder: (context, error, stackTrace) {
            return Icon(fallbackIcon, color: color, size: size);
          },
        );
      },
    );
  }
}

class ProfileAvatar extends StatefulWidget {
  final String? imageUrl;
  final double radius;
  final File? localImage;
  final Uint8List? webImage;
  final VoidCallback? onCameraTap;
  final double? borderWidth;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    required this.radius,
    this.localImage,
    this.webImage,
    this.onCameraTap,
    this.borderWidth,
  });

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  String? _token;
  bool _errorLoadingImage = false;
  Uint8List? _networkImageBytes;
  bool _isLoadingNetworkImage = false;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    _token = await ApiService.getToken();
    if (mounted) {
      setState(() {});
      if (kIsWeb) {
        _fetchNetworkImageBytes();
      }
    }
  }

  @override
  void didUpdateWidget(ProfileAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      if (kIsWeb) {
        _fetchNetworkImageBytes();
      } else {
        setState(() {
          _errorLoadingImage = false;
        });
      }
    }
  }

  Future<void> _fetchNetworkImageBytes() async {
    if (widget.imageUrl == null ||
        widget.imageUrl!.isEmpty ||
        widget.imageUrl!.contains("null") ||
        _errorLoadingImage) {
      return;
    }

    if (mounted) {
      setState(() {
        _isLoadingNetworkImage = true;
        _networkImageBytes = null;
        _errorLoadingImage = false;
      });
    }

    final bool isStorageUrl = widget.imageUrl!.contains('/storage/');

    try {
      final response = await http.get(
        Uri.parse(widget.imageUrl!),
        headers: (isStorageUrl || _token == null)
            ? null
            : {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _networkImageBytes = response.bodyBytes;
            _isLoadingNetworkImage = false;
          });
        }
      } else {
        // Log the error but don't throw to avoid crashing the state
        debugPrint('ProfileAvatar: Failed to load image. Status: ${response.statusCode}');
        if (mounted) {
          setState(() {
            _errorLoadingImage = true;
            _isLoadingNetworkImage = false;
          });
        }
      }
    } catch (e) {
      debugPrint('ProfileAvatar: Error fetching image bytes: $e');
      if (mounted) {
        setState(() {
          _errorLoadingImage = true;
          _isLoadingNetworkImage = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    ImageProvider? provider;

    final bool hasValidImageUrl = widget.imageUrl != null &&
        widget.imageUrl!.isNotEmpty &&
        !widget.imageUrl!.contains("null") &&
        !_errorLoadingImage;

    if (kIsWeb && widget.webImage != null) {
      provider = MemoryImage(widget.webImage!);
    } else if (kIsWeb && _networkImageBytes != null) {
      provider = MemoryImage(_networkImageBytes!);
    } else if (kIsWeb && hasValidImageUrl) {
      provider = NetworkImage(widget.imageUrl!);
    } else if (!kIsWeb && widget.localImage != null) {
      provider = FileImage(widget.localImage!);
    } else if (!kIsWeb && hasValidImageUrl) {
      final bool isStorageUrl = widget.imageUrl!.contains('/storage/');
      provider = NetworkImage(
        widget.imageUrl!,
        headers: isStorageUrl
            ? null
            : {
                if (_token != null) 'Authorization': 'Bearer $_token',
                'User-Agent':
                    'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36',
                'Accept':
                    'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
              },
      );
    }

    // Use our custom placeholder if no provider is available
    if (provider == null) {
      provider = const AssetImage('assets/images/random_boy.jpg');
    }

    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(context.scale(4)),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: widget.borderWidth == 0
                ? null
                : Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    width: widget.borderWidth ?? 2,
                  ),
          ),
          child: CircleAvatar(
            radius: widget.radius,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            backgroundImage: provider,
            onBackgroundImageError: (exception, stackTrace) {
              debugPrint(
                  'ProfileAvatar: Error loading image ${widget.imageUrl}: $exception');
              if (mounted && !_errorLoadingImage) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _errorLoadingImage = true;
                    });
                  }
                });
              }
            },
          ),
        ),
        if (widget.onCameraTap != null)
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: widget.onCameraTap,
              child: CircleAvatar(
                radius: context.scale(18),
                backgroundColor: theme.colorScheme.primary,
                child: Icon(
                  Icons.camera_alt_rounded,
                  size: context.scale(18),
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class ProfileBadge extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const ProfileBadge({super.key, required this.label, required this.value, this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.scale(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
              fontSize: context.font(10),
            ),
          ),
          SizedBox(height: context.scale(6)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: context.scale(16),
              vertical: context.scale(12),
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(context.scale(12)),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: context.scale(18), color: theme.colorScheme.primary),
                  SizedBox(width: context.scale(12)),
                ],
                Expanded(
                  child: Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                      fontSize: context.font(13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QuickActionItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final double? width;

  const QuickActionItem({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final effectiveColor = color ?? colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.scale(20)),
      child: Container(
        width: width,
        padding: EdgeInsets.symmetric(
          vertical: context.scale(16),
          horizontal: context.scale(8),
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(context.scale(20)),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Container(
                padding: EdgeInsets.all(context.scale(4)),
                decoration: BoxDecoration(
                  color: effectiveColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: context.scale(20),
                  color: effectiveColor,
                ),
              ),
            ),
            SizedBox(height: context.scale(4)),
            Text(
              label,
              style: TextStyle(
                fontSize: context.font(10),
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
