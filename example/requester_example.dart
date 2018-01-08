import 'dart:async';
import 'package:requester/requester.dart';
import 'package:http/http.dart';

Future main() async {
  var client = new Client();
  var requester = new Requester(client);
  requester.addMiddleware(new LoggingMiddleware());
  var request = new HackernewsRequest("dart");
  await requester.send(request);
  print('done!');
}

class HackernewsRequest extends Request {
  HackernewsRequest(String query)
      : super("GET",
            Uri.parse("http://hn.algolia.com/api/v1/search?query=$query")) {
    this.headers['Content-Type'] = 'application/json';
  }
}

class LoggingMiddleware extends BaseMiddleware {
  LoggingMiddleware();

  void prepare(BaseRequest request) {
    printCurl(request);
  }

  void handle(Response response) {
    print("Response: ${response.statusCode}");
    print(response.body);
  }

  void printCurl(BaseRequest request) {
    var curlCmd = "curl";
    curlCmd += " -X " + request.method;
    var compressed = false;
    request.headers.forEach((name, value) {
      if (name?.toLowerCase() == "accept-encoding" &&
          value?.toLowerCase() == "gzip") {
        compressed = true;
      }
      curlCmd += " -H \"$name: $value\"";
    });
    if (request.method == 'POST' || request.method == 'PUT') {
      if (request is Request) {
        var body = request.body;
        curlCmd += " --data '$body'";
      }
    }
    curlCmd += (compressed ? " --compressed " : " ") + request.url.toString();
    print("╭--- cURL (${request.url})");
    print(curlCmd);
    print("╰--- (copy and paste the above line to a terminal)");
  }
}
