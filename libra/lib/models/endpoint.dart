class Endpoint {
  String url;
  int version;
  bool is_avail;

  Endpoint({
    required this.url,
    this.version = 0,
    this.is_avail = false,
  });


}