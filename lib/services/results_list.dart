import '../tools/list.dart';
import '../data/results.dart';
import 'database.dart';

class ResultsList extends ItemList<Result> {
  final int parent_id;
  ResultsList({required DBInstance db, required this.parent_id})
      : super(db: db, db_table: 'results');

  /// Get events from db and from ics calendar
  @override
  fill() async {
    List<Map<String, Object?>> raw_cat = await (await db.db).rawQuery(
        '''select * from results c'''
        ''' join competitions_results cr on c.id = cr.result'''
        ''' where cr.competition = ?''',
        [parent_id]);

    list = raw_cat.map((e) {
      return Result(
        id: e['id'] as int,
        name: e['name'].toString(),
        pdf: e['pdf'].toString(),
        published_at:
            DateTime.fromMillisecondsSinceEpoch(e['published_at'] as int),
      );
    }).toList();
  }

  @override
  toString() {
    return "ResultsList($list.map((e) => e.toString())}";
  }

  /// Save results to db and link them to competitions
  save() async {
    await super.save_list();

    var batch = (await db.db).batch();
    for (var result in list) {
      batch.execute('insert into competitions_results values (?, ?)',
          [parent_id, result.id]);
    }
    batch.commit();
  }
}
