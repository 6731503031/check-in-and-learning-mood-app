import 'package:check_in_and_learning_mood_app/app.dart';
import 'package:check_in_and_learning_mood_app/services/in_memory_session_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders home page title', (tester) async {
    await tester.pumpWidget(
      CheckInMoodApp(
        repository: InMemorySessionRepository(),
        usingFirestore: false,
      ),
    );

    expect(find.text('Check-in & Learning Mood'), findsOneWidget);
    expect(find.text('Choose your role'), findsOneWidget);
    expect(find.text('Student'), findsOneWidget);
    expect(find.text('Teacher'), findsOneWidget);
  });
}
