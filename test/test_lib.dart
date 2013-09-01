library test_lib;
import 'package:unittest/unittest.dart';
import 'package:bson/bson.dart';
import 'package:mongo_dart_query/mongo_dart_query.dart';
testSelectorBuilderCreation(){
  SelectorBuilder selector = where;
  expect(selector.map is Map, isTrue);
  expect(selector.map,isEmpty);
}
testSelectorBuilderOnObjectId(){
  ObjectId id = new ObjectId();
  SelectorBuilder selector = where.id(id);
  expect(selector.map is Map, isTrue);
  expect(selector.map.length,greaterThan(0));
  expect(selector.map,equals({r'$query':{'_id': id}}));
}

testQueries() {
  var selector = where.gt("my_field", 995).sortBy('my_field');
  expect(selector.map,{r'$query': {'my_field': {r'$gt': 995}}, 'orderby': {'my_field': 1}});
  selector = where.inRange("my_field", 700, 703, minInclude: false).sortBy('my_field');
  expect(selector.map,{r'$query': {'my_field': {r'$gt': 700, r'$lt': 703}}, 'orderby': {'my_field': 1}});
  selector = where.eq("my_field", 17).fields(['str_field']);
  expect(selector.map,{r'$query': {'my_field': 17}});
  expect(selector.paramFields,{'str_field':1});
  selector = where.sortBy('a').skip(300);
  expect(selector.map,equals({'\$query': {}, 'orderby': {'a': 1}}));
  selector = where.hint('bar').hint('baz', descending: true).explain();
  expect(selector.map,equals({'\$query': {}, '\$hint': {'bar': 1, 'baz': -1}, '\$explain': true}));
  
}

testQueryComposition() {
  SelectorBuilder selector = where.gt("a", 995).eq('b', 'bbb');
  expect(selector.map,equals({r'$query': {'\$and': [{'a':{ r'$gt': 995}},{'b':'bbb'}]}}));
  selector = where.gt('a', 995).lt('a', 1000);
  expect(selector.map,equals({r'$query': {'\$and': [{'a':{ r'$gt': 995}},{'a':{ r'$lt': 1000}}]}}));
  selector = where.gt('a', 995).and(where.lt('b', 1000).or(where.gt('c', 2000)));
  expect(selector.map,{'\$query': {'\$and': [{'a': {'\$gt': 995}}, {'\$or': [{'b': {'\$lt': 1000}}, {'c': {'\$gt': 2000}}]}]}});
  selector = where.lt('b', 1000).or(where.gt('c', 2000)).and(where.gt('a', 995));
  expect(selector.map,{'\$query': {'\$and': [{'\$or': [{'b': {'\$lt': 1000}}, {'c': {'\$gt': 2000}}]},{'a': {'\$gt': 995}}]}});
  selector = where.lt('b', 1000).or(where.gt('c', 2000)).gt('a', 995);
  expect(selector.map,{'\$query': {'\$and': [{'\$or': [{'b': {'\$lt': 1000}}, {'c': {'\$gt': 2000}}]},{'a': {'\$gt': 995}}]}});
  selector = where.lt('b', 1000).or(where.gt('c', 2000)).or(where.gt('a', 995));
  expect(selector.map,{'\$query': {'\$or': [{'b': {'\$lt': 1000}}, {'c': {'\$gt': 2000}} ,{'a': {'\$gt': 995}}]}});
  selector = where.eq('price', 1.99).and(where.lt('qty',20).or(where.eq('sale', true)));
  expect(selector.map, {'\$query': {'\$and': [{'price':1.99}, {'\$or': [{'qty': {'\$lt': 20 }}, {'sale': true }]}]}});
  selector = where.eq('price', 1.99).and(where.lt('qty',20)).and(where.eq('sale', true));
  expect(selector.map, {'\$query': {'\$and': [{'price':1.99},{'qty': {'\$lt': 20 }}, {'sale': true }]}});
  selector = where.eq('price', 1.99).lt('qty', 20).eq('sale', true);
  expect(selector.map, {'\$query': {'\$and': [{'price':1.99},{'qty': {'\$lt': 20 }}, {'sale': true }]}});
  selector = where.eq('foo', 'bar').or(where.eq('foo', 'baz')).eq('name', 'jack');
  print(selector.getQueryString());
}

testModifierBuilder() {
  var modifier = modify.set("a", 995).set('b', 'bbb');
  expect(modifier.map,equals({r'$set': {'a': 995, 'b':'bbb'}}));
  modifier = modify.unset("a").unset('b');
  expect(modifier.map,equals({r'$unset': {'a': 1, 'b':1}}));
}

run(){
  test("testSelectorBuilderCreation",testSelectorBuilderCreation);
  test("testSelectorBuilderOnObjectId",testSelectorBuilderOnObjectId);
  test("testQueries",testQueries);
  test('testQueryComposition',testQueryComposition);
  test('testModifierBuilder',testModifierBuilder);
}