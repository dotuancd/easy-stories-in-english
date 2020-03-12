
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Some", () {

    final baseUrl = "https://httpbin.org/somewhere///";

    final result = baseUrl.replaceFirst(new RegExp(r"(/+$)"), "");

    expect(result, "https://httpbin.org/somewhere/");
  });
}