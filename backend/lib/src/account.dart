/// A seeded demo account — same identities and passwords as the Flutter
/// app's `DevMockAuthRemoteDataSource`, so switching `AppConfig.useMockAuth`
/// to false doesn't change which demo credentials work.
class Account {
  final String id;
  final String name;
  final String email;
  final String password;
  final String role;

  const Account({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
  };
}

const seedAccounts = [
  Account(
    id: 'citizen@taarak.dev',
    name: 'Citizen Demo',
    email: 'citizen@taarak.dev',
    password: 'citizen123',
    role: 'citizen',
  ),
  Account(
    id: 'responder@taarak.dev',
    name: 'Responder Demo',
    email: 'responder@taarak.dev',
    password: 'responder123',
    role: 'fieldResponder',
  ),
  Account(
    id: 'official@taarak.dev',
    name: 'Local Official Demo',
    email: 'official@taarak.dev',
    password: 'official123',
    role: 'localOfficial',
  ),
  Account(
    id: 'command@taarak.dev',
    name: 'District Command Demo',
    email: 'command@taarak.dev',
    password: 'command123',
    role: 'districtCommand',
  ),
  Account(
    id: 'stateadmin@taarak.dev',
    name: 'State Admin Demo',
    email: 'stateadmin@taarak.dev',
    password: 'stateadmin123',
    role: 'stateAdmin',
  ),
  Account(
    id: 'sysadmin@taarak.dev',
    name: 'System Admin Demo',
    email: 'sysadmin@taarak.dev',
    password: 'sysadmin123',
    role: 'systemAdmin',
  ),
];
