// Ficheiro: lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // --- DEFINIÇÃO DAS CORES DA PALETA "FOCO E CRESCIMENTO" ---
  static const Color primaryColor = Color(0xFF2E8B57); // Verde Esmeralda (Menus e Topbars)
  static const Color backgroundColor = Color(0xFFF0FFF0); // Verde Menta (Fundo das telas)
  static const Color accentColor = Color(0xFFFFC107); // Amarelo Âmbar (Botões e Destaques)
  static const Color textPrimary = Color(0xFF1E293B); // Cinza Escuro para textos
  static const Color textSecondary = Color(0xFF64748B); // Cinza Claro para subtítulos

  // --- CONFIGURAÇÃO DO TEMA GLOBAL ---
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: 'Roboto', // Mantendo a tipografia que já usamos
      
      // Estilo global da AppBar (Barras Superiores)
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white, 
          fontSize: 20, 
          fontWeight: FontWeight.bold,
        ),
      ),

      // Estilo global dos Botões Elevados (Primários)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      // Estilo global para Floating Action Buttons ou botões de destaque
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: textPrimary,
      ),

      // Estilo para a Barra de Navegação Inferior do Mobile
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}