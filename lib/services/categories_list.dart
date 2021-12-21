
import '../data/category.dart';
import '../tools/list.dart';
import '../config.dart' as config;
import 'database.dart';

class CategoriesList extends ItemList<Category> {
  final int parent_id;
  CategoriesList({required DBInstance db, required this.parent_id})
    : super(db: db, db_table: 'categories');

  /// Get events from db and from ics calendar
  @override
  fill() async {

    List<Map<String, Object?>> raw_cat = await (await db.db).rawQuery(
      '''select * from categories c'''
      ''' join articles_categories ac on c.id = ac.category'''
      ''' where ac.article = ?''', [parent_id]);

    items.value = raw_cat.map((e) {
      dynamic id = e['id'];
      return Category(
          id: id,
          slug: e['slug'].toString(),
          name: e['name'].toString()
      );
    }).toList();
  }

  @override
  toString() {
    return "CategoriesList(${items.value.map((e) => e.toString())}";
  }

  /// Save categories to db and link them to articles
  save() async {
    print('saving categories for $parent_id');
    super.save_list();

    var batch = (await db.db).batch();
    for (var cat in items.value) {
      batch.execute('insert into articles_categories values (?, ?)', [parent_id, cat.id]);
    }
    batch.commit();
  }

  /// Get most weighted category
  Category? get_first() {
    var cats = items.value;
    cats.sort((a, b)  {
        var wa = config.categories_weight[a.slug];
        var wb = config.categories_weight[b.slug];
        return (wa == null || wb == null) ? 0 : wb.compareTo(wa);
    });
    return cats.isNotEmpty ? cats.first : null;
  }
}
