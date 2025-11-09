import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_grist_widgets/src/services/grist_service.dart';

void main() {
  group('GristService', () {
    group('hashPassword', () {
      test('generates bcrypt hash', () {
        final hash = GristService.hashPassword('testPassword123');

        // Bcrypt hashes start with $2a$, $2b$, or $2y$
        expect(hash, startsWith(r'$2'));

        // Bcrypt hashes are 60 characters long
        expect(hash.length, equals(60));
      });

      test('generates different hashes for same password (salted)', () {
        final hash1 = GristService.hashPassword('samePassword');
        final hash2 = GristService.hashPassword('samePassword');

        // Hashes should be different due to different salts
        expect(hash1, isNot(equals(hash2)));
      });

      test('generates different hashes for different passwords', () {
        final hash1 = GristService.hashPassword('password1');
        final hash2 = GristService.hashPassword('password2');

        expect(hash1, isNot(equals(hash2)));
      });

      test('handles empty password', () {
        final hash = GristService.hashPassword('');
        expect(hash, isNotEmpty);
        expect(hash, startsWith(r'$2'));
      });

      test('handles special characters', () {
        final hash = GristService.hashPassword('p@ssw0rd!#\$%');
        expect(hash, isNotEmpty);
        expect(hash, startsWith(r'$2'));
      });

      test('handles unicode characters', () {
        final hash = GristService.hashPassword('пароль密码🔐');
        expect(hash, isNotEmpty);
        expect(hash, startsWith(r'$2'));
      });

      test('handles very long passwords', () {
        final longPassword = 'a' * 200;
        final hash = GristService.hashPassword(longPassword);
        expect(hash, isNotEmpty);
        expect(hash, startsWith(r'$2'));
      });
    });
  });
}
