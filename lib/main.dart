import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_provider_data/block/block_post.dart';
import 'package:flutter_provider_data/page/main_menu_admin.dart';
import 'package:flutter_provider_data/page/login_page.dart';
import 'package:flutter_provider_data/page/main_menu_leader.dart';
import 'package:flutter_provider_data/provider/employee_provider.dart';
import 'package:flutter_provider_data/provider/jobnumber_provider.dart';
import 'package:flutter_provider_data/provider/machine_provider.dart';
import 'package:flutter_provider_data/provider/material_provider.dart';
import 'package:flutter_provider_data/provider/ng_provider.dart';
import 'package:flutter_provider_data/provider/pending_provider.dart';
import 'package:flutter_provider_data/provider/reason_provider.dart';
import 'package:flutter_provider_data/provider/record_provider.dart';
import 'package:flutter_provider_data/provider/running_provider.dart';
import 'package:flutter_provider_data/provider/testing_provider.dart';
import 'package:flutter_provider_data/service/record_service.dart';
import 'package:flutter_provider_data/service/running_service.dart';
import 'package:flutter_provider_data/service/testing_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  // Load environment file secara dinamis
  const String env = String.fromEnvironment('ENV', defaultValue: 'dev');

  await dotenv.load(fileName: '.env.$env'); // contoh: .env.dev, .env.prod

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TestingProvider>(
          create: (_) => TestingProvider(TestingService(http.Client())),
        ),
        ChangeNotifierProvider<RecordProvider>(
            create: (_) => RecordProvider(service: RecordService())),
        ChangeNotifierProvider<ReasonProvider>(create: (_) => ReasonProvider()),
        ChangeNotifierProvider<MaterialProvider>(
            create: (_) => MaterialProvider()),
        ChangeNotifierProvider<JobNumberProvider>(
            create: (_) => JobNumberProvider()),
        ChangeNotifierProvider<MachineProvider>(
            create: (_) => MachineProvider()),
        ChangeNotifierProvider<EmployeeProvider>(
            create: (_) => EmployeeProvider()),
        ChangeNotifierProxyProvider<EmployeeProvider, PendingProvider>(
          create: (_) => PendingProvider.initial(),
          update: (_, employeeProvider, pendingProvider) =>
              pendingProvider!..attachEmployeeProvider(employeeProvider),
        ),
        ChangeNotifierProvider<RunningProvider>(
          create: (_) => RunningProvider(service: RunningService()),
        ),
        ChangeNotifierProvider<BlockPost>(create: (_) => BlockPost()),
        ChangeNotifierProvider<NGProvider>(
          create: (_) => NGProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'MANPRO - ${dotenv.env['ENV']}',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textTheme: GoogleFonts.poppinsTextTheme(),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginPage(),
          '/landing': (context) => const MainMenuAdmin(),
          '/main_menu_operator': (context) =>
              const MainMenuLeader(title: "MAIN MENU")
        },
      ),
    );
  }
}

// https://711588521942.signin.aws.amazon.com/console
// dev-aan
//ProdOpt01
//ManagAdm01
//ProdLead@123
