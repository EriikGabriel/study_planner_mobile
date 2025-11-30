import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:study_planner/pages/login_page.dart';
import 'package:study_planner/providers/theme_provider.dart';
import 'package:study_planner/providers/user_provider.dart';
import 'package:study_planner/theme/app_theme.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context).colorScheme;
    final currentTheme = ref.watch(themeProvider);
    final isDarkMode = currentTheme.brightness == Brightness.dark;
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header - Informações do usuário
                _buildUserHeader(context, theme, user),

                const SizedBox(height: 32),

                // Seção de Aparência
                _buildSectionTitle(context, theme, "Aparência"),
                const SizedBox(height: 12),
                _buildThemeToggle(context, theme, ref, isDarkMode),

                const SizedBox(height: 32),

                // Seção de Conta
                _buildSectionTitle(context, theme, "Conta"),
                const SizedBox(height: 12),
                _buildAccountOptions(context, theme, user),

                const SizedBox(height: 32),

                // Seção de Sobre
                _buildSectionTitle(context, theme, "Sobre"),
                const SizedBox(height: 12),
                _buildAboutOptions(context, theme),

                const SizedBox(height: 32),

                // Botão de Logout
                _buildLogoutButton(context, theme, ref),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, ColorScheme theme, User? user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primary.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: theme.primary,
            child: Text(
              user?.email?.substring(0, 1).toUpperCase() ?? 'U',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'Usuário',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'email@exemplo.com',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: theme.secondaryText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    ColorScheme theme,
    String title,
  ) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: theme.secondaryText,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildThemeToggle(
    BuildContext context,
    ColorScheme theme,
    WidgetRef ref,
    bool isDarkMode,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isDarkMode ? Icons.dark_mode : Icons.light_mode,
            color: theme.primary,
          ),
        ),
        title: Text(
          'Modo Escuro',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: theme.primaryText,
          ),
        ),
        subtitle: Text(
          isDarkMode ? 'Ativado' : 'Desativado',
          style: GoogleFonts.poppins(fontSize: 13, color: theme.secondaryText),
        ),
        trailing: Switch(
          value: isDarkMode,
          onChanged: (value) {
            ref.read(themeProvider.notifier).toggleTheme();
          },
          activeThumbColor: theme.primary,
        ),
      ),
    );
  }

  Widget _buildAccountOptions(
    BuildContext context,
    ColorScheme theme,
    User? user,
  ) {
    return Column(
      children: [
        _buildSettingItem(
          context,
          theme,
          icon: Icons.person_outline,
          title: 'Editar Perfil',
          onTap: () {
            // TODO: Implementar edição de perfil
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Em desenvolvimento')));
          },
        ),
        const SizedBox(height: 8),
        _buildSettingItem(
          context,
          theme,
          icon: Icons.lock_outline,
          title: 'Alterar Senha',
          onTap: () {
            // TODO: Implementar alteração de senha
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Em desenvolvimento')));
          },
        ),
        const SizedBox(height: 8),
        _buildSettingItem(
          context,
          theme,
          icon: Icons.notifications_outlined,
          title: 'Notificações',
          onTap: () {
            // TODO: Implementar configurações de notificações
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Em desenvolvimento')));
          },
        ),
      ],
    );
  }

  Widget _buildAboutOptions(BuildContext context, ColorScheme theme) {
    return Column(
      children: [
        _buildSettingItem(
          context,
          theme,
          icon: Icons.info_outline,
          title: 'Sobre o App',
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                  'Study Planner',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Versão 1.0.0', style: GoogleFonts.poppins()),
                    const SizedBox(height: 8),
                    Text(
                      'Um aplicativo para gerenciar suas matérias e atividades acadêmicas.',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fechar'),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        _buildSettingItem(
          context,
          theme,
          icon: Icons.privacy_tip_outlined,
          title: 'Política de Privacidade',
          onTap: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Em desenvolvimento')));
          },
        ),
        const SizedBox(height: 8),
        _buildSettingItem(
          context,
          theme,
          icon: Icons.help_outline,
          title: 'Ajuda',
          onTap: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Em desenvolvimento')));
          },
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    ColorScheme theme, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: theme.primary),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: theme.primaryText,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: theme.secondaryText,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton(
    BuildContext context,
    ColorScheme theme,
    WidgetRef ref,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                'Sair da Conta',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              content: Text(
                'Tem certeza que deseja sair?',
                style: GoogleFonts.poppins(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Sair'),
                ),
              ],
            ),
          );

          if (confirm == true && context.mounted) {
            await FirebaseAuth.instance.signOut();
            ref.read(userProvider.notifier).signOut();

            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[50],
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, size: 20),
            const SizedBox(width: 8),
            Text(
              'Sair da Conta',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
