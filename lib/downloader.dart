
import 'dart:io';

import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class LocalFile {
  final Downloader _downloader;

  final String directory;

  LocalFile(this._downloader, {this.directory = ''});

  Future<String> get _storageDirectory async {
    final paths = await getExternalCacheDirectories();

    return path.join(paths.first.path, directory);
  }

  Future<File> get(String filename) async {

  }

  Future<bool> exists(String filename) async {


  }
}

class Downloader {

  final Client _client;

  Downloader(this._client);

  Future<Stream> download(String url) {

  }
}