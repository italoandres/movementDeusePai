import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jornada_deus_pai/features/entry/presentation/screens/entry_screen.dart';
import 'package:jornada_deus_pai/features/carta/presentation/screens/carta_screen.dart';
import 'package:jornada_deus_pai/features/auth/presentation/screens/login_screen.dart';
import 'package:jornada_deus_pai/features/auth/presentation/screens/signup_screen.dart';
import 'package:jornada_deus_pai/features/home/presentation/screens/journey_home_screen.dart';
import 'package:jornada_deus_pai/features/home/presentation/screens/book_journey_screen.dart';
import 'package:jornada_deus_pai/features/sales/presentation/screens/sales_screen.dart';
import 'package:jornada_deus_pai/features/sales/presentation/screens/thank_you_screen.dart';
import 'package:jornada_deus_pai/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:jornada_deus_pai/features/book/presentation/pages/book_home_page.dart';
import 'package:jornada_deus_pai/features/book/presentation/pages/book_intro_page.dart';
import 'package:jornada_deus_pai/features/book/presentation/pages/chapter_reading_page.dart';
import 'package:jornada_deus_pai/features/consciousness_journey/presentation/screens/intro_screen.dart';
import 'package:jornada_deus_pai/features/consciousness_journey/presentation/screens/quiz_screen.dart';
import 'package:jornada_deus_pai/features/consciousness_journey/presentation/screens/result_reveal_screen.dart';
import 'package:jornada_deus_pai/features/consciousness_journey/presentation/screens/loading_screen.dart';
import 'package:jornada_deus_pai/features/consciousness_journey/presentation/screens/emotional_result_screen.dart';
import 'package:jornada_deus_pai/features/consciousness_journey/presentation/screens/sales_page_screen.dart';
import 'package:jornada_deus_pai/features/consciousness_journey/presentation/screens/free_access_screen.dart';
import 'package:jornada_deus_pai/features/consciousness_journey/presentation/screens/access_created_screen.dart';
import 'package:jornada_deus_pai/shared/core/app_routes.dart';
import 'package:jornada_deus_pai/shared/services/supabase_service.dart';

/// App Router Configuration
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.entry,
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      final isAuthenticated = SupabaseService.instance.isAuthenticated;
      final isGoingToAuth = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signup;
      final isGoingToSales = state.matchedLocation == AppRoutes.sales;
      final isGoingToCheckout = state.matchedLocation == AppRoutes.checkout;
      final isGoingToThankYou = state.matchedLocation == AppRoutes.thankYou;
      final isGoingToBook = state.matchedLocation.startsWith('/book');

      // Allow access to sales, checkout, thank you, book pages, journey, and home without authentication
      if (isGoingToSales || isGoingToCheckout || isGoingToThankYou || isGoingToBook || state.matchedLocation.startsWith('/journey') || state.matchedLocation == '/' || state.matchedLocation == '/receber-carta' || state.matchedLocation == '/obrigado' || state.matchedLocation == '/acesso-criado' || state.matchedLocation == '/home' || state.matchedLocation == '/livro') {
        return null;
      }

      // Redirect to login if not authenticated and not going to auth screens
      if (!isAuthenticated && !isGoingToAuth) {
        return AppRoutes.login;
      }

      // Redirect to home if authenticated and going to auth screens
      if (isAuthenticated && isGoingToAuth) {
        return '/home';
      }

      // No redirect needed
      return null;
    },
    routes: [
      // Consciousness Journey - Main Entry Point (/)
      GoRoute(
        path: AppRoutes.entry,
        name: AppRoutes.entryName,
        builder: (context, state) => const JourneyIntroScreen(),
      ),

      // Journey Quiz
      GoRoute(
        path: '/journey/quiz',
        name: 'journeyQuiz',
        builder: (context, state) => const QuizScreen(),
      ),

      // Journey Reveal (micro silence)
      GoRoute(
        path: '/journey/reveal',
        name: 'journeyReveal',
        builder: (context, state) => const ResultRevealScreen(),
      ),

      // Journey Loading (contemplative)
      GoRoute(
        path: '/journey/loading',
        name: 'journeyLoading',
        builder: (context, state) => const JourneyLoadingScreen(),
      ),

      // Journey Emotional Result
      GoRoute(
        path: '/journey/result',
        name: 'journeyResult',
        builder: (context, state) => const EmotionalResultScreen(),
      ),

      // Journey Sales Page
      GoRoute(
        path: '/journey/sales',
        name: 'journeySales',
        builder: (context, state) => const SalesPageScreen(),
      ),

      // Free Access - "Receber a Carta"
      GoRoute(
        path: '/receber-carta',
        name: 'receberCarta',
        builder: (context, state) => const FreeAccessScreen(),
      ),

      // Access Created - "porta silenciosa se abrindo"
      GoRoute(
        path: '/acesso-criado',
        name: 'acessoCriado',
        builder: (context, state) => const AccessCreatedScreen(),
      ),

      // Journey Home - main authenticated environment
      GoRoute(
        path: '/home',
        name: 'journeyHome',
        builder: (context, state) => const JourneyHomeScreen(),
      ),

      // Book Journey - internal page "Não Ore, Fale com o Pai" (inside ecosystem)
      GoRoute(
        path: '/livro',
        name: 'bookJourney',
        builder: (context, state) => const BookJourneyScreen(),
      ),

      // Book Home (after purchase/access)
      GoRoute(
        path: '/book-home',
        name: AppRoutes.bookHomeName,
        builder: (context, state) => const BookHomePage(),
      ),
      
      // Old Entry Screen (reference)
      GoRoute(
        path: '/entry-old',
        name: 'entryOld',
        builder: (context, state) => const EntryScreen(),
      ),

      // Carta de um Órfão (Livro 1)
      GoRoute(
        path: AppRoutes.carta,
        name: AppRoutes.cartaName,
        builder: (context, state) => const CartaScreen(),
      ),

      // Book (alternative route to Book Home)
      GoRoute(
        path: '/book',
        name: 'book',
        builder: (context, state) => const BookHomePage(),
      ),

      // Book Introduction
      GoRoute(
        path: '/book/intro',
        name: 'bookIntro',
        builder: (context, state) => const BookIntroPage(),
      ),

      // Book Chapter Reading
      GoRoute(
        path: '/book/chapter/:chapterId',
        name: 'chapterReading',
        builder: (context, state) {
          final chapterIdStr = state.pathParameters['chapterId'] ?? '1';
          final chapterId = int.tryParse(chapterIdStr) ?? 1;
          return ChapterReadingPage(chapterId: chapterId);
        },
      ),

      // Auth Screens
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.loginName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: AppRoutes.signupName,
        builder: (context, state) => const SignupScreen(),
      ),

      // Sales Landing Page (accessible without authentication)
      GoRoute(
        path: AppRoutes.sales,
        name: AppRoutes.salesName,
        builder: (context, state) => const SalesScreen(),
      ),

      // Checkout Page (accessible without authentication)
      GoRoute(
        path: AppRoutes.checkout,
        name: AppRoutes.checkoutName,
        builder: (context, state) => const CheckoutScreen(),
      ),

      // Thank You Page (accessible without authentication)
      GoRoute(
        path: AppRoutes.thankYou,
        name: AppRoutes.thankYouName,
        builder: (context, state) => ThankYouScreen(
          email: state.uri.queryParameters['external_reference'],
        ),
      ),

      // Obrigado Page (alias - same as thank you, used by checkout)
      GoRoute(
        path: '/obrigado',
        name: 'obrigado',
        builder: (context, state) => ThankYouScreen(
          email: state.uri.queryParameters['external_reference'],
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Página não encontrada: ${state.matchedLocation}'),
      ),
    ),
  );
}
