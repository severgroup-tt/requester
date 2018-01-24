# requester

Send `package:http` requests with middleware

## example

```dart
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

// response:
//   ╭--- cURL (http://hn.algolia.com/api/v1/search?query=dart)
//   curl -X GET -H "Content-Type: application/json" http://hn.algolia.com/api/v1/search?query=dart
//   ╰--- (copy and paste the above line to a terminal)
//   Response: 200
//   {"hits":[{"created_at":"2011-10-10T07:03:34.000Z" ...
//   done!
```

see the full example in the /example directory.
