class EmailValidation {
  String? username;
  String? domain;
  String? emailAddress;
  String? formatCheck;
  String? smtpCheck;
  String? dnsCheck;
  String? freeCheck;
  String? disposableCheck;
  String? catchAllCheck;
  List<String>? mxRecords;
  Audit? audit;

  EmailValidation(
      {this.username,
        this.domain,
        this.emailAddress,
        this.formatCheck,
        this.smtpCheck,
        this.dnsCheck,
        this.freeCheck,
        this.disposableCheck,
        this.catchAllCheck,
        this.mxRecords,
        this.audit});

  EmailValidation.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    domain = json['domain'];
    emailAddress = json['emailAddress'];
    formatCheck = json['formatCheck'];
    smtpCheck = json['smtpCheck'];
    dnsCheck = json['dnsCheck'];
    freeCheck = json['freeCheck'];
    disposableCheck = json['disposableCheck'];
    catchAllCheck = json['catchAllCheck'];
    mxRecords = json['mxRecords'].cast<String>();
    audit = json['audit'] != null ? new Audit.fromJson(json['audit']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['username'] = this.username;
    data['domain'] = this.domain;
    data['emailAddress'] = this.emailAddress;
    data['formatCheck'] = this.formatCheck;
    data['smtpCheck'] = this.smtpCheck;
    data['dnsCheck'] = this.dnsCheck;
    data['freeCheck'] = this.freeCheck;
    data['disposableCheck'] = this.disposableCheck;
    data['catchAllCheck'] = this.catchAllCheck;
    data['mxRecords'] = this.mxRecords;
    if (this.audit != null) {
      data['audit'] = this.audit!.toJson();
    }
    return data;
  }
}

class Audit {
  String? auditCreatedDate;
  String? auditUpdatedDate;

  Audit({this.auditCreatedDate, this.auditUpdatedDate});

  Audit.fromJson(Map<String, dynamic> json) {
    auditCreatedDate = json['auditCreatedDate'];
    auditUpdatedDate = json['auditUpdatedDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['auditCreatedDate'] = this.auditCreatedDate;
    data['auditUpdatedDate'] = this.auditUpdatedDate;
    return data;
  }
}
