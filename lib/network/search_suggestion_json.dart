class SearchSuggestions {
  List<String>? suggestions;
  List<int>? weights;
  Null error;

  SearchSuggestions({this.suggestions, this.weights, this.error});

  SearchSuggestions.fromJson(Map<String, dynamic> json) {
    suggestions = json['suggestions'].cast<String>();
    weights = json['weights'].cast<int>();
    error = json['error'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['suggestions'] = this.suggestions;
    data['weights'] = this.weights;
    data['error'] = this.error;
    return data;
  }
}
