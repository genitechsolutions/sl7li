import 'package:flutter/material.dart';

/// خدمة بشبكة "الخدمات الشائعة"؛ [id] هو serviceId بالخلفية.
class PopularService {
  const PopularService({required this.name, required this.id, this.image, this.icon});

  final String name;
  final String id;
  final String? image;
  final IconData? icon;
}

const popularServices = [
  PopularService(name: 'الدهانات', id: 'painting_molding', image: 'assets/images/ic_paint.png'),
  PopularService(name: 'التكييف', id: 'air_conditioning', image: 'assets/images/ic_ac.png'),
  PopularService(
    name: 'الكهرباء',
    id: 'electrical_repair',
    image: 'assets/images/ic_electricity.png',
  ),
  PopularService(name: 'السباكة', id: 'plumbing_repair', image: 'assets/images/ic_plumbing.png'),
  PopularService(name: 'النجارة', id: 'carpentry', icon: Icons.carpenter_outlined),
  PopularService(name: 'الأجهزة المنزلية', id: 'appliance_repair', icon: Icons.kitchen_outlined),
  PopularService(
    name: 'التنظيف',
    id: 'deep_cleaning_entire_home',
    icon: Icons.cleaning_services_outlined,
  ),
];
