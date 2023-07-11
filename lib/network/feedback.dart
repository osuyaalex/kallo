class FeedbackSent {
  Null? data;
  Null? error;

  FeedbackSent({this.data, this.error});

  FeedbackSent.fromJson(Map<String, dynamic> json) {
    data = json['data'];
    error = json['error'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['data'] = this.data;
    data['error'] = this.error;
    return data;
  }
}