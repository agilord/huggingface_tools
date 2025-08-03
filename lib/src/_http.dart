import 'package:http/http.dart';

Future<R> withHttpClient<R>({
  Client? client,
  required Future<R> Function(Client client) fn,
}) async {
  final close = client == null;
  final c = client ?? Client();
  try {
    return await fn(c);
  } finally {
    if (close) {
      c.close();
    }
  }
}
