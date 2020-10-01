import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';

/// Sends [BaseRequest] and returns the [Response] after applying all middleware
class Requester {
  final Client _client;
  final List<Middleware> _middleware;
  final Encoding defaultResponseEncoding;

  Requester(this._client, {this.defaultResponseEncoding = utf8}) : _middleware = [];

  Future<Response> send(BaseRequest request) async {
    _middleware.forEach((i) => i.prepare(request));
    var stream = await _client.send(request);
    var response = await Response.fromStream(stream);

    if (defaultResponseEncoding != null) {
      final contentType = response.headers['content-type'];
      if (contentType != null) {
        var mediaType = MediaType.parse(contentType);
        if (!mediaType.parameters.containsKey("charset")) {
          mediaType = mediaType.change(parameters: {'charset': defaultResponseEncoding.name});
          response.headers['content-type'] = mediaType.toString();        
        }
      }
    }

    // Reverse the middleware so that the last middlware to prepare the request
    // is the first to handle the response.
    _middleware.reversed.forEach((m) => m.handle(response));
    return response;
  }

  void addMiddleware(Middleware m) {
    _middleware.add(m);
  }

  void addAllMiddleware(Iterable<Middleware> m) {
    _middleware.addAll(m);
  }
}

abstract class Middleware {
  void prepare(BaseRequest request);
  void handle(Response response);
}

class BaseMiddleware implements Middleware {
  void prepare(BaseRequest request) {}
  void handle(Response response) {}
}
