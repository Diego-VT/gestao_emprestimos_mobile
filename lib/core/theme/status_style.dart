import 'package:flutter/material.dart';

import 'app_colors.dart';

class StatusStyle {
  const StatusStyle({
    required this.color,
    required this.softColor,
    required this.textColor,
  });

  final Color color;
  final Color softColor;
  final Color textColor;

  static StatusStyle fromStatus(String status) {
    final normalizado = status
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('â', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c');

    if (normalizado.contains('pendente')) {
      return const StatusStyle(
        color: AppColors.pending,
        softColor: AppColors.pendingSoft,
        textColor: AppColors.pending,
      );
    }
    if (normalizado.contains('aprovada')) {
      return const StatusStyle(
        color: AppColors.approved,
        softColor: AppColors.approvedSoft,
        textColor: Color(0xFF166534),
      );
    }
    if (normalizado.contains('analise')) {
      return const StatusStyle(
        color: AppColors.analysis,
        softColor: AppColors.analysisSoft,
        textColor: AppColors.primary,
      );
    }
    if (normalizado.contains('concluida')) {
      return const StatusStyle(
        color: AppColors.completed,
        softColor: AppColors.neutralSoft,
        textColor: AppColors.textPrimary,
      );
    }
    if (normalizado.contains('manutencao')) {
      return const StatusStyle(
        color: AppColors.maintenance,
        softColor: AppColors.maintenanceSoft,
        textColor: AppColors.maintenance,
      );
    }
    return const StatusStyle(
      color: AppColors.textSecondary,
      softColor: AppColors.neutralSoft,
      textColor: AppColors.textPrimary,
    );
  }
}
