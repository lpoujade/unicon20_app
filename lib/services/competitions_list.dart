/// Manage competitions list

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:sqflite/sqflite.dart';
import 'package:unicon/tools/list.dart';

import '../data/competition.dart';
import 'database.dart';
import '../config.dart' as config;
import 'results_list.dart';

/// Hold a list of [Competition], a connection to [Database] and
/// handle connections to wordpress
class CompetitionsList extends ItemList<Competition> {

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

	 raw_competitions.map((e) {
			 return Competition(
					 id: e['id'] as int,
					 name: e['name'].toString(),
					 updated_at: DateTime.fromMillisecondsSinceEpoch(e['updated_at'] as int),
					 competitor_list_pdf:e['competitor_list_pdf'].toString(),
					 start_list_pdf: ['start_list_pdf'].toString(),
					 results: ResultsList(db: db, parent_id: e['id'] as int)
			 );
			 }).toList();
     await refresh();
  }

	Future<List<Competition>> refresh() async {
		var url = Uri.parse(config.competition_api_path);
		var new_comps = [];
		Map<String, dynamic> competitionsList;
		var client = RetryClient(http.Client(),
				whenError: (_o, _s) => true,
				retries: 3);
		Map<String, String> auth_headers = {HttpHeaders.authorizationHeader: 'Token ${config.competition_api_token}'};
		try {
			print('get $url');
			var response = await client.read(url, headers: auth_headers).timeout(const Duration(seconds: 60));
			competitionsList = json.decode(response);
		} catch(err) {
			print('ERROR downloading competitions');
			rethrow;
		} finally { client.close(); }
		// print(competitionsList);
		var competitions = competitionsList['competitions'];
		// print(competitions);
		// {name: Basket - , competitor_list_pdf: null, start_list_pdf: null, results: null, updated_at: 2021-10-19T06:35:13-05:00}
		for (final comp in competitions) {
			var comp_id = Random().nextInt(1000);
			var results = ResultsList(db: db, parent_id: comp_id);
			var _comp = Competition(
						id: comp_id,
						name: comp['name'],
						competitor_list_pdf: comp['competition_list_pdf'],
						start_list_pdf: comp['start_list_pdf'],
						updated_at: DateTime.parse(comp['updated_at']),
						results: results
						);
			new_comps.add(_comp);
			add(_comp);
		}
		return [];
	}
}
