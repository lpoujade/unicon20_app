/// Manage competitions list

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:sqflite/sqflite.dart';

import '../data/competition.dart';
import '../data/results.dart';
import '../tools/list.dart';
import 'database.dart';
import '../config.dart' as config;
import 'results_list.dart';

/// Hold a list of [Competition], a connection to [Database] and
/// handle connections to the registration website API
class CompetitionsList extends ItemList<Competition> {
  String? _lang;

  CompetitionsList({required DBInstance db})
      : super(db: db, db_table: 'competitions');

  @override
  save_list() async {
    await super.save_list();
    for (var r in list) await r.results.save();
  }

  /// Get competitions from db and from api
  @override
  fill() async {
    var raw_competitions = await super.get_from_db();

    list = raw_competitions.map((e) {
      return Competition(
          id: e['id'] as int,
          name: e['name'].toString(),
          updated_at:
              DateTime.fromMillisecondsSinceEpoch(e['updated_at'] as int),
          competitor_list_pdf: e['competitor_list_pdf'].toString(),
          start_list_pdf: e['start_list_pdf'].toString(),
          results: ResultsList(db: db, parent_id: e['id'] as int));
    }).toList();
    await refresh();
  }

  /// Read current language from db
  init_lang() async {
    _lang = await db.get_locale();
  }

  Future<List<Competition>> refresh() async {
    if (_lang == null) {
      await init_lang();
    }

    var url = Uri.parse(config.competition_api_host +
        config.competition_api_path.replaceFirst('LANG', _lang ?? 'en'));
    var new_comps = [];
    Map<String, dynamic> competitionsList;
    var client =
        RetryClient(http.Client(), whenError: (o, s) => true, retries: 3);
    Map<String, String> auth_headers = {
      HttpHeaders.authorizationHeader: 'Token ${config.competition_api_token}'
    };
    try {
      var response = await client
          .read(url, headers: auth_headers)
          .timeout(const Duration(seconds: 60));
      competitionsList = json.decode(response);
    } catch (err) {
      print('ERROR downloading competitions');
      rethrow;
    } finally {
      client.close();
    }
    var competitions = competitionsList['competitions'];
    for (final comp in competitions) {
      var comp_id = comp['id'];
      var results = ResultsList(db: db, parent_id: comp_id);
      if (comp['results'] != null) {
        for (final res in comp['results']) {
          var res_id = res['id'];
          results.add(Result(
              id: res_id,
              name: res['name'],
              published_at: DateTime.parse(res['published_at']),
              pdf: res['pdf']));
        }
      }
      new_comps.add(Competition(
          id: comp_id,
          name: comp['name'],
          competitor_list_pdf: comp['competition_list_pdf'],
          start_list_pdf: comp['start_list_pdf'],
          updated_at: DateTime.parse(comp['updated_at']),
          results: results));
      list = new_comps;
    }
    save_list();
    return [];
  }
}
