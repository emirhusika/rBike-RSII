import 'package:flutter/material.dart';
import 'package:rbike_admin/layouts/master_screen.dart';
import 'package:rbike_admin/models/user.dart';
import 'package:rbike_admin/providers/popup_dialogs.dart';
import 'package:rbike_admin/providers/user_provider.dart';
import 'package:rbike_admin/models/search_result.dart';
import 'package:rbike_admin/widgets/pagination_widget.dart';
import 'package:rbike_admin/providers/role_provider.dart';
import 'package:rbike_admin/models/mail_object.dart';
import 'package:rbike_admin/providers/mail_provider.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final UserProvider _userProvider = UserProvider();
  final MailProvider _mailProvider = MailProvider();
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  SearchResult<User>? _result;
  bool _isLoading = false;
  int _currentPage = 1;
  final int _pageSize = 10;
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final filter = {
        'page': _currentPage,
        'pageSize': _pageSize,
        if (_usernameController.text.isNotEmpty)
          'username': _usernameController.text,
      };
      final result = await _userProvider.get(filter: filter);
      setState(() {
        _result = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Greška pri učitavanju korisnika: \\${e.toString()}'),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleUserStatus(User user) async {
    final isActivating = !(user.status ?? false);
    final action = isActivating ? 'aktivirati' : 'deaktivirati';
    final question = 'Jeste li sigurni da želite $action ovog korisnika?';
    await MyDialogs.showQuestion(context, question, () async {
      try {
        await _userProvider.updateStatus(user.userId!, isActivating);
        await MyDialogs.showSuccess(
          context,
          'Korisnik je uspješno ${isActivating ? 'aktiviran' : 'deaktiviran'}.',
          () async {
            await _loadData();
          },
        );
      } catch (e) {
        await MyDialogs.showError(
          context,
          'Greška pri promjeni statusa: \\${e.toString()}',
        );
      }
    });
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(9.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: "Korisničko ime"),
              onSubmitted: (_) => _onSearch(),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _onSearch,
            icon: const Icon(Icons.search),
            label: const Text("Pretraga"),
          ),
        ],
      ),
    );
  }

  void _onSearch() {
    setState(() {
      _currentPage = 1;
    });
    _loadData();
  }

  Widget _buildPaginationControls() {
    return PaginationWidget(
      currentPage: _currentPage,
      totalCount: _result?.count ?? 0,
      pageSize: _pageSize,
      isLoading: _isLoading,
      onPageChanged: (newPage) {
        setState(() => _currentPage = newPage);
        _loadData();
      },
    );
  }

  Future<void> _showSendMailDialog(User user) async {
    final _formKey = GlobalKey<FormState>();
    String subject = '';
    String message = '';
    bool isLoading = false;
    bool isSuccess = false;
    String? errorMsg;
    int messageMaxLength = 500;
    await showDialog(
      context: context,
      barrierDismissible: !isLoading,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.email_outlined, color: Colors.blue, size: 28),
                  SizedBox(width: 8),
                  Text('Pošalji email korisniku'),
                ],
              ),
              content:
                  isSuccess
                      ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                            size: 48,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Email uspješno poslan!',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                      : SizedBox(
                        width: 400,
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextFormField(
                                  initialValue: user.email ?? '',
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(Icons.person_outline),
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  readOnly: true,
                                ),
                                SizedBox(height: 16),
                                TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Naslov',
                                    prefixIcon: Icon(Icons.title_outlined),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    helperText: 'Unesite naslov emaila',
                                  ),
                                  validator:
                                      (v) =>
                                          v == null || v.isEmpty
                                              ? 'Obavezno polje'
                                              : null,
                                  onSaved: (v) => subject = v ?? '',
                                ),
                                SizedBox(height: 16),
                                TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Poruka',
                                    prefixIcon: Icon(Icons.message_outlined),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    helperText: 'Unesite sadržaj poruke',
                                  ),
                                  maxLines: 5,
                                  maxLength: messageMaxLength,
                                  validator:
                                      (v) =>
                                          v == null || v.isEmpty
                                              ? 'Obavezno polje'
                                              : null,
                                  onSaved: (v) => message = v ?? '',
                                ),
                                if (errorMsg != null) ...[
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          errorMsg!,
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
              actions:
                  isSuccess
                      ? [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Zatvori'),
                        ),
                      ]
                      : [
                        TextButton(
                          onPressed:
                              isLoading
                                  ? null
                                  : () => Navigator.of(context).pop(),
                          child: Text('Odustani'),
                        ),
                        ElevatedButton.icon(
                          onPressed:
                              isLoading
                                  ? null
                                  : () async {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      _formKey.currentState?.save();
                                      setState(() {
                                        isLoading = true;
                                        errorMsg = null;
                                      });
                                      try {
                                        await _mailProvider.sendMail(
                                          MailObject(
                                            emailAddress: user.email ?? '',
                                            subject: subject,
                                            message: message,
                                          ),
                                        );
                                        setState(() {
                                          isSuccess = true;
                                          isLoading = false;
                                        });
                                      } catch (e) {
                                        setState(() {
                                          errorMsg =
                                              'Greška pri slanju emaila: ${e.toString()}';
                                          isLoading = false;
                                        });
                                      }
                                    }
                                  },
                          icon:
                              isLoading
                                  ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : Icon(Icons.send),
                          label: Text('Pošalji'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            textStyle: TextStyle(fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Korisnici",
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.person_add),
                label: const Text('Dodaj korisnika'),
                onPressed: () => _showAddUserDialog(context),
              ),
            ),
          ),
          _buildSearch(),
          Expanded(
            child: Scrollbar(
              controller: _verticalScrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _verticalScrollController,
                child: Column(
                  children: [
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _result == null || _result!.result.isEmpty
                        ? const Center(child: Text('Nema korisnika.'))
                        : Scrollbar(
                          thumbVisibility: true,
                          controller: _horizontalScrollController,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            controller: _horizontalScrollController,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Ime')),
                                DataColumn(label: Text('Prezime')),
                                DataColumn(label: Text('Email')),
                                DataColumn(label: Text('Telefon')),
                                DataColumn(label: Text('Korisničko ime')),
                                DataColumn(label: Text('Status')),
                                DataColumn(label: Text('Datum registracije')),
                                DataColumn(label: Text('Uloge')),
                                DataColumn(label: Text('Akcija')),
                                DataColumn(label: Text('Pošalji email')),
                              ],
                              rows:
                                  _result!.result.map((user) {
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(user.firstName ?? '')),
                                        DataCell(Text(user.lastName ?? '')),
                                        DataCell(Text(user.email ?? '')),
                                        DataCell(Text(user.phone ?? '')),
                                        DataCell(Text(user.username ?? '')),
                                        DataCell(
                                          Text(
                                            (user.status ?? false)
                                                ? 'Aktivan'
                                                : 'Neaktivan',
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            user.dateRegistered != null
                                                ? user.dateRegistered!
                                                    .toLocal()
                                                    .toString()
                                                    .split(' ')[0]
                                                : '',
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            user.userRoles
                                                    ?.map(
                                                      (ur) =>
                                                          ur.role?.name ?? '',
                                                    )
                                                    .where(
                                                      (name) => name.isNotEmpty,
                                                    )
                                                    .join(', ') ??
                                                '',
                                          ),
                                        ),
                                        DataCell(
                                          ElevatedButton(
                                            onPressed:
                                                () => _toggleUserStatus(user),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  (user.status ?? false)
                                                      ? Colors.red
                                                      : Colors.green,
                                              foregroundColor: Colors.white,
                                            ),
                                            child: Text(
                                              (user.status ?? false)
                                                  ? 'Deaktiviraj'
                                                  : 'Aktiviraj',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          ElevatedButton(
                                            onPressed:
                                                () => _showSendMailDialog(user),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                              foregroundColor: Colors.white,
                                            ),
                                            child: Text('Pošalji email'),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                            ),
                          ),
                        ),
                    _buildPaginationControls(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddUserDialog(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();
    String? firstName,
        lastName,
        email,
        phone,
        username,
        password,
        confirmPassword;
    bool status = true;
    DateTime? dateRegistered = DateTime.now();
    Role? selectedRole;
    String? errorMsg;

    List<Role> rolesList = [];
    bool rolesLoading = true;
    try {
      final roleProvider = RoleProvider();
      final result = await roleProvider.get();
      rolesList = result.result;
      rolesLoading = false;
    } catch (e) {
      rolesLoading = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Greška pri učitavanju uloga: \\${e.toString()}'),
        ),
      );
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding: const EdgeInsets.all(0),
              title: Row(
                children: [
                  Icon(Icons.person_add, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  const Text(
                    'Dodaj korisnika',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: SizedBox(
                width: 440,
                child:
                    rolesLoading
                        ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                        : SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 8),
                                  Text(
                                    'Osnovni podaci',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Ime',
                                    ),
                                    validator:
                                        (v) =>
                                            v == null || v.isEmpty
                                                ? 'Obavezno polje'
                                                : null,
                                    onSaved: (v) => firstName = v,
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Prezime',
                                    ),
                                    validator:
                                        (v) =>
                                            v == null || v.isEmpty
                                                ? 'Obavezno polje'
                                                : null,
                                    onSaved: (v) => lastName = v,
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Email',
                                    ),
                                    onSaved: (v) => email = v,
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Telefon',
                                    ),
                                    onSaved: (v) => phone = v,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Prijava',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Korisničko ime',
                                    ),
                                    validator:
                                        (v) =>
                                            v == null || v.isEmpty
                                                ? 'Obavezno polje'
                                                : null,
                                    onSaved: (v) => username = v,
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Lozinka',
                                    ),
                                    obscureText: true,
                                    validator:
                                        (v) =>
                                            v == null || v.isEmpty
                                                ? 'Obavezno polje'
                                                : null,
                                    onSaved: (v) => password = v,
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Potvrdi lozinku',
                                    ),
                                    obscureText: true,
                                    validator: (v) {
                                      if (v == null || v.isEmpty)
                                        return 'Obavezno polje';
                                      if (password != null && v != password)
                                        return 'Lozinke se ne poklapaju.';
                                      return null;
                                    },
                                    onSaved: (v) => confirmPassword = v,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Ostalo',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<Role>(
                                    decoration: const InputDecoration(
                                      labelText: 'Uloga',
                                    ),
                                    items:
                                        rolesList
                                            .map(
                                              (role) => DropdownMenuItem(
                                                value: role,
                                                child: Text(role.name ?? ''),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (role) => selectedRole = role,
                                    validator:
                                        (v) =>
                                            v == null ? 'Obavezno polje' : null,
                                  ),
                                  SwitchListTile(
                                    title: const Text('Aktivan'),
                                    value: status,
                                    onChanged:
                                        (v) => setState(() => status = v),
                                  ),
                                  if (errorMsg != null) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.red[50],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            color: Colors.red[700],
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              errorMsg!,
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Odustani'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      _formKey.currentState?.save();
                      try {
                        final newUser = await _userProvider.insert({
                          'firstName': firstName,
                          'lastName': lastName,
                          'email': email,
                          'phone': phone,
                          'username': username,
                          'password': password,
                          'confirmPassword': confirmPassword,
                          'status': status,
                          'dateRegistered': dateRegistered?.toIso8601String(),
                          'userRoles':
                              selectedRole != null
                                  ? [
                                    {'roleId': selectedRole!.roleId},
                                  ]
                                  : [],
                        });
                        Navigator.of(context).pop();
                        await _loadData();
                      } catch (e) {
                        String err = e.toString();
                        if (err.contains('Username is already taken')) {
                          setState(
                            () => errorMsg = 'Korisničko ime je zauzeto.',
                          );
                        } else if (err.contains('Email is already taken')) {
                          setState(() => errorMsg = 'Email je zauzet.');
                        } else {
                          setState(
                            () =>
                                errorMsg =
                                    'Greška pri dodavanju korisnika: ' + err,
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Spremi'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
