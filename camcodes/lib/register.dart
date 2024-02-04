import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'bike_data.dart';

void main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
  print('Server running on ${server.address}:${server.port}');
  
  final databaseHelper = DatabaseHelper();

  await for (HttpRequest request in server) {
    if (request.method == 'POST') {
      try {
        final requestData = await utf8.decoder.bind(request).join();
        final parts = requestData.replaceAll('(', '').replaceAll(')', '').split(',');
        if (parts.length == 2) {
          final station = int.tryParse(parts[0].trim());
          final bike = int.tryParse(parts[1].trim());
          if (station != null && bike != null) {
            await databaseHelper.updateBikeStation({'Station': station, 'Bike': bike, 'Status': 0});
            print('Status updated for station: $station, bike: $bike');
            request.response
              ..statusCode = HttpStatus.ok
              ..write('Status updated for station: $station, bike: $bike');
          } else {
            request.response
              ..statusCode = HttpStatus.badRequest
              ..write('Invalid station or bike');
          }
        } else {
          request.response
            ..statusCode = HttpStatus.badRequest
            ..write('Invalid request format');
        }
      } catch (e) {
        request.response
          ..statusCode = HttpStatus.internalServerError
          ..write('Internal Server Error: $e');
      } finally {
        await request.response.close();
      }
    } else {
      request.response
        ..statusCode = HttpStatus.methodNotAllowed
        ..write('Unsupported method: ${request.method}');
      await request.response.close();
    }
  }
}
