class SearchResult<T> {
  int count = 0;
  List<T> result = [];

  SearchResult();

  SearchResult.withData({required this.result, required this.count});

  factory SearchResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    var resultList =
        (json['resultList'] as List)
            .map((item) => fromJsonT(item as Map<String, dynamic>))
            .toList();

    return SearchResult.withData(
      result: resultList,
      count: json['count'] as int,
    );
  }
}
