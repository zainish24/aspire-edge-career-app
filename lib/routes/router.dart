import 'package:flutter/material.dart';
import 'package:aspire_edge/models/resource_model.dart';
import 'package:aspire_edge/models/testimonial_model.dart';
import '../../screens/admin_screens/feedback/views/admin_feedback_career_screen.dart';
import '../../screens/admin_screens/feedback/views/admin_feedback_detail_screen.dart';
import '../../screens/user_screens/bookmark/views/bookmark_screen.dart';
import '../../screens/user_screens/home/views/home_screen.dart';
import 'package:aspire_edge/user_entry_point.dart';
import 'package:aspire_edge/admin_entry_point.dart';
import 'screen_export.dart';

import 'package:aspire_edge/models/career_model.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    // 🔹 Onboarding
    case onbordingScreenRoute:
      return MaterialPageRoute(
        builder: (_) => const OnboardingScreen(),
      );

//auth
    case logInScreenRoute:
      return MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      );
    case signUpScreenRoute:
      return MaterialPageRoute(
        builder: (_) => const SignUpScreen(),
      );
    case chooseVerificationMethodScreenRoute:
      return MaterialPageRoute(
        builder: (_) => const ChooseVerificationMethodScreen(),
      );

    // 🔹 User App Entry
    case userEntryPointScreenRoute:
      return MaterialPageRoute(builder: (_) => const UserEntryPoint());
    case adminEntryPointScreenRoute:
      return MaterialPageRoute(builder: (_) => const AdminEntryPoint());

    // 🔹 User App Screens

    case careerBankScreenRoute:
      return MaterialPageRoute(builder: (_) => const CareerBankScreen());

    

    case userCareerDetailScreenRoute:
      final arguments = settings.arguments as Map<String, dynamic>?;
      final careerId = arguments?['careerId'] as String?;
      if (careerId == null) {
        return MaterialPageRoute(
            builder: (_) => const Scaffold(
                body: Center(child: Text('Career ID is required'))));
      }
      return MaterialPageRoute(
          builder: (_) => CareerDetailsScreen(careerId: careerId));

    case feedbackScreenRoute:
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (_) => UserCareerFeedbackScreen(
          careerId: args['careerId'],
          careerTitle: args['careerTitle'],
        ),
      );

    case addFeedbackScreenRoute:
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (_) => AddFeedbackScreen(
          careerId: args['careerId'],
          careerTitle: args['careerTitle'],
        ),
      );

    case editFeedbackScreenRoute:
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (_) => EditFeedbackScreen(
          feedback: args['feedback'],
        ),
      );
    case userTestimonialScreenRoute:
      return MaterialPageRoute(builder: (_) => const UserTestimonialScreen());

    case resourceScreenRoute:
      return MaterialPageRoute(builder: (_) => const ResourcesScreen());

    case bookMarkScreenRoute:
      return MaterialPageRoute(builder: (_) => const BookmarkScreen());

    case homeScreenRoute:
      return MaterialPageRoute(builder: (_) => const HomeScreen());

    case editProfileRoute:
      return MaterialPageRoute(builder: (_) => const EditProfileScreen());

    case profileScreenRoute:
      return MaterialPageRoute(
          builder: (_) => const ProfileScreen(
                userId: '',
                userName: '',
              ));

    // 🔹 Admin Panel Entry

    case adminHomeScreenRoute:
      return MaterialPageRoute(builder: (_) => const AdminHomeScreen());

    case adminCareerListScreenRoute:
      return MaterialPageRoute(builder: (_) => const AdminCareerListScreen());
    case adminAddEditCareerScreenRoute:
      final args = settings.arguments as Map<String, dynamic>?;
      return MaterialPageRoute(
        builder: (_) => AdminCareerAddEditScreen(
          careerId: args?['careerId'] as String?,
          careerData: args?['careerData'] as CareerModel?,
        ),
      );

    case adminAddEditQuizScreenRoute:
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (_) => AdminAddEditQuizScreen(
          careerId: args['careerId'],
          careerData: args['careerData'],
          quizData: args['quizData'],
        ),
      );

    case adminCareerDetailScreenRoute:
      final career = settings.arguments as CareerModel;
      return MaterialPageRoute(
        builder: (_) => AdminCareerDetailScreen(
          careerId: career.careerId,
        ),
      );

    case adminIndustryManagementScreenRoute:
      return MaterialPageRoute(
          builder: (_) => const AdminIndustryManagementScreen());

    case adminCareerEducationScreenRoute:
      return MaterialPageRoute(
          builder: (_) => const AdminCareerEducationScreen());

    case adminSkillManagementScreenRoute:
      return MaterialPageRoute(
          builder: (_) => const AdminSkillManagementScreen(
                educationId: '',
                educationName: '',
              ));

    case adminCareerFeedbackListScreenRoute:
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
          builder: (_) => AdminCareerFeedbackScreen(
                careerId: args['careerId'],
                careerTitle: args['careerTitle'],
              ));

    case adminFeedbackDetailScreenRoute:
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
          builder: (_) => AdminFeedbackDetailScreen(
                feedback: args['feedback'],
              ));

    case adminUserAddScreenRoute:
      return MaterialPageRoute(builder: (_) => AdminUserAddScreen());

    case adminUserEditScreenRoute:
      return MaterialPageRoute(builder: (_) => AdminUserEditScreen());

    case adminUserDetailScreenRoute:
      return MaterialPageRoute(builder: (_) => AdminUserDetailScreen());

// In your route generator
    case adminResourceDetailScreenRoute:
      return MaterialPageRoute(builder: (_) => AdminResourceDetailScreen());

    case adminUserListScreenRoute:
      return MaterialPageRoute(builder: (_) => AdminUserListScreen());

    case adminQuizListScreenRoute:
      return MaterialPageRoute(builder: (_) => AdminQuizListScreen());

    case adminResourceListScreenRoute:
      return MaterialPageRoute(builder: (_) => AdminResourceListScreen());

    case adminFeedbackListScreenRoute:
      return MaterialPageRoute(builder: (_) => AdminFeedbackListScreen());

    case adminTestimonialListScreenRoute:
      return MaterialPageRoute(builder: (_) => AdminTestimonialListScreen());

    case adminTestimonialDetailScreenRoute:
     final Testimonial testimonial = settings.arguments as Testimonial;
  return MaterialPageRoute(
    builder: (_) => AdminTestimonialDetailScreen(testimonial: testimonial),
  );

    case addTestimonialScreenRoute:
      return MaterialPageRoute(builder: (_) => AddTestimonialScreen());

    case adminResourceScreenRoute:
      final args = settings.arguments as Map<String, dynamic>?;
      if (args != null &&
          args.containsKey('careerId') &&
          args.containsKey('careerTitle')) {
        return MaterialPageRoute(
          builder: (_) => AdminCareerResourcesScreen(
            careerId: args['careerId'] as String,
            careerTitle: args['careerTitle'] as String,
          ),
        );
      } else {
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Invalid arguments for resource screen'),
            ),
          ),
        );
      }

    case adminAddEditResourceScreenRoute:
      final args = settings.arguments as Map<String, dynamic>?;
      if (args != null &&
          args.containsKey('careerId') &&
          args.containsKey('careerTitle')) {
        return MaterialPageRoute(
          builder: (_) => AdminAddEditResourceScreen(
            careerId: args['careerId'] as String,
            careerTitle: args['careerTitle'] as String,
            resource:
                args.containsKey('resourceData') && args['resourceData'] != null
                    ? args['resourceData'] as ResourceModel
                    : null,
          ),
        );
      } else {
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Invalid arguments for add/edit resource screen'),
            ),
          ),
        );
      }

    case adminEditProfileRoute:
      return MaterialPageRoute(builder: (_) => const AdminEditProfileScreen());

    case adminProfileScreenRoute:
      return MaterialPageRoute(
          builder: (_) => const AdminProfileScreen(
                userId: '',
                userName: '',
              ));

    // 🔹 Default Fallback
    default:
      return MaterialPageRoute(builder: (_) => const OnboardingScreen());
  }
}
