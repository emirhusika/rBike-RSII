class MailObject {
  final String emailAddress;
  final String subject;
  final String message;

  MailObject({required this.emailAddress, required this.subject, required this.message});

  Map<String, dynamic> toJson() => {
    'emailAddress': emailAddress,
    'subject': subject,
    'message': message,
  };
} 