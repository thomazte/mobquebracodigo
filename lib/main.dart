import 'package:flutter/material.dart';

import 'services/auth_session.dart';
import 'theme/qc_theme.dart';
import 'views/cadastro_view.dart';
import 'views/cursos_view.dart';
import 'views/home2_view.dart';
import 'views/home_view.dart';
import 'views/jogos_view.dart';
import 'views/login_view.dart';
import 'views/perfil_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthSession.instance.bootstrap();
  runApp(const QuebraCodigoApp());
}

class QuebraCodigoApp extends StatelessWidget {
  const QuebraCodigoApp({super.key});

  Route<dynamic> _buildRoute(RouteSettings settings, Widget page) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 180),
      reverseTransitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        return FadeTransition(opacity: fade, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final routes = <String, WidgetBuilder>{
      '/': (_) => const HomeView(),
      '/login': (_) => const LoginView(),
      '/cadastro': (_) => const CadastroView(),
      '/home2': (_) => const Home2View(),
      '/perfil': (_) => const PerfilView(),
      '/cursos': (_) => const CursosView(),
      '/jogos': (_) => const JogosView(),
    };

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quebra Código',
      theme: QcTheme.dark(),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final builder = routes[settings.name];
        if (builder != null) {
          return _buildRoute(settings, builder(context));
        }
        return _buildRoute(settings, const HomeView());
      },
    );
  }
}
