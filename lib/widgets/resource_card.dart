import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/material_model.dart';
import '../theme/app_theme.dart';

/// ResourceCard renders official textbooks and online platforms from the GTU syllabus.
class ResourceCard extends StatelessWidget {
  final ResourceModel resource;

  const ResourceCard({super.key, required this.resource});

  Future<void> _openUrl(BuildContext context, String? url) async {
    if (url == null || url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch $url'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBook = resource.type == ResourceType.book;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Badge
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isBook ? AppTheme.academicGold : AppTheme.primaryCyan)
                      .withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: (isBook
                            ? AppTheme.academicGold
                            : AppTheme.primaryCyan)
                        .withValues(alpha: 0.4),
                  ),
                ),
                child: Icon(
                  resource.iconData,
                  size: 22,
                  color:
                      isBook ? AppTheme.academicGold : AppTheme.primaryCyan,
                ),
              ),
              const SizedBox(width: 14),

              // Title & Type Tag
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isBook ? 'TEXTBOOK' : 'ONLINE RESOURCE',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: isBook
                                  ? AppTheme.academicGold
                                  : AppTheme.primaryCyan,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      resource.title,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Author / Org: ${resource.authorOrOrg}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            resource.description,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.textMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: resource.url != null
                  ? () => _openUrl(context, resource.url)
                  : null,
              icon: Icon(
                resource.url != null
                    ? Icons.open_in_new_rounded
                    : Icons.book_rounded,
                size: 16,
              ),
              label: Text(
                resource.url != null ? 'View Resource Link' : 'Reference Book',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isBook
                    ? AppTheme.academicGold.withValues(alpha: 0.2)
                    : AppTheme.primaryCyan.withValues(alpha: 0.2),
                foregroundColor:
                    isBook ? AppTheme.academicGold : AppTheme.primaryCyan,
                side: BorderSide(
                  color: isBook
                      ? AppTheme.academicGold.withValues(alpha: 0.5)
                      : AppTheme.primaryCyan.withValues(alpha: 0.5),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
