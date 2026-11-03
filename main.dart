import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main()=>runApp(const ChickenZone());
const red=Color(0xFFC81020), blue=Color(0xFF173B73), green=Color(0xFF087D39);
class ChickenZone extends StatelessWidget{
 const ChickenZone({super.key});
 @override Widget build(BuildContext c)=>MaterialApp(title:'TU Chicken Zone',debugShowCheckedModeBanner:false,
 theme:ThemeData(useMaterial3:true,colorScheme:ColorScheme.fromSeed(seedColor:red),scaffoldBackgroundColor:const Color(0xfff5f6f8),appBarTheme:const AppBarTheme(backgroundColor:red,foregroundColor:Colors.white)),
 home:const MainPage());
}
class Entry{
 String kind,date,detail; double amount;
 Entry(this.kind,this.date,this.detail,this.amount);
 Map<String,dynamic> toJson()=>{'kind':kind,'date':date,'detail':detail,'amount':amount};
 factory Entry.fromJson(Map<String,dynamic> j)=>Entry(j['kind'],j['date'],j['detail'],(j['amount'] as num).toDouble());
}
class MainPage extends StatefulWidget{const MainPage({super.key});@override State<MainPage> createState()=>_MainPageState();}
class _MainPageState extends State<MainPage>{
 int tab=0;String shop='Chicken Zone';List<Entry> entries=[];
 @override void initState(){super.initState();load();}
 Future<void> load()async{final p=await SharedPreferences.getInstance();final list=jsonDecode(p.getString('entries')??'[]') as List; if(!mounted)return;setState(()=>entries=list.map((e)=>Entry.fromJson(Map<String,dynamic>.from(e))).toList());shop=p.getString('shop')??'Chicken Zone';}
 Future<void> save()async{final p=await SharedPreferences.getInstance();await p.setString('entries',jsonEncode(entries.map((e)=>e.toJson()).toList()));}
 double sum(String k)=>entries.where((e)=>e.kind==k).fold(0,(a,e)=>a+e.amount);
 String cash(double n)=>'Rs. ${n.toStringAsFixed(0)}';
 Future<void> add(String kind)async{
  final d=TextEditingController(),a=TextEditingController();final key=GlobalKey<FormState>();
  final ok=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(title:Text('Add $kind'),content:Form(key:key,child:Column(mainAxisSize:MainAxisSize.min,children:[
   TextFormField(controller:d,decoration:const InputDecoration(labelText:'Name / Details / نوٹ')),
   TextFormField(controller:a,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Amount (PKR)'),validator:(v)=>double.tryParse(v??'')==null?'Valid amount required':null)])),
   actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancel')),FilledButton(onPressed:(){if(key.currentState!.validate())Navigator.pop(ctx,true);},child:const Text('Save'))]));
  if(ok==true){setState(()=>entries.insert(0,Entry(kind,DateTime.now().toIso8601String().substring(0,10),d.text,double.parse(a.text))));await save();}
  d.dispose();a.dispose();
 }
 @override Widget build(BuildContext context){
  final views=[dashboard(),mall(),customers(),reports(),settings()];
  return Scaffold(appBar:AppBar(title:Text('🐓 $shop')),
   body:views[tab],
   bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(i)=>setState(()=>tab=i),destinations:const[
    NavigationDestination(icon:Icon(Icons.home),label:'Home'),NavigationDestination(icon:Icon(Icons.scale),label:'Mall'),NavigationDestination(icon:Icon(Icons.people),label:'Customers'),NavigationDestination(icon:Icon(Icons.bar_chart),label:'Reports'),NavigationDestination(icon:Icon(Icons.settings),label:'More')]));
 }
 Widget dashboard()=>ListView(padding:const EdgeInsets.all(12),children:[
  Container(height:145,padding:const EdgeInsets.all(18),decoration:BoxDecoration(borderRadius:BorderRadius.circular(18),gradient:const LinearGradient(colors:[red,Color(0xff79000c)])),child:const Column(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.start,children:[Text('TU CHICKEN ZONE',style:TextStyle(color:Colors.white,fontSize:25,fontWeight:FontWeight.w900)),Text('Management System • Poultry Business Solution',style:TextStyle(color:Colors.white)),Text('مرغی کاروبار مینجمنٹ سسٹم',style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold))])),
  const SizedBox(height:12),
  GridView.count(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisCount:2,childAspectRatio:1.45,crossAxisSpacing:8,mainAxisSpacing:8,children:[
   metric('Total Mall','— Kg',Icons.scale,blue),metric('Mall Ki Qeemat',cash(sum('Purchase')),Icons.currency_rupee,red),metric('Mall Mein Kami','— Kg',Icons.remove_circle,Colors.orange),metric('Total Purchase',cash(sum('Purchase')),Icons.shopping_cart,green),metric('Total Sale',cash(sum('Sale')),Icons.point_of_sale,blue),metric('Customer Udhaar',cash(sum('Credit')),Icons.people,Colors.purple),metric('Today Profit',cash(sum('Sale')-sum('Purchase')-sum('Expense')),Icons.trending_up,green),metric('Expense',cash(sum('Expense')),Icons.money_off,red)]),
  const SizedBox(height:12),const Text('Quick Actions',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
  Wrap(spacing:7,runSpacing:7,children:['Purchase','Sale','Credit','Expense'].map((k)=>FilledButton(onPressed:()=>add(k),child:Text(k))).toList()),
  const SizedBox(height:10),const Text('Recent Records',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
  if(entries.isEmpty)const Card(child:Padding(padding:EdgeInsets.all(16),child:Text('No entries yet. Add a record from Quick Actions.'))),
  ...entries.take(8).map((e)=>Card(child:ListTile(leading:const Icon(Icons.receipt,color:red),title:Text(e.kind),subtitle:Text('${e.date} • ${e.detail}'),trailing:Text(cash(e.amount))))),
 ]);
 Widget metric(String t,String v,IconData i,Color c)=>Card(child:Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Icon(i,color:c,size:26),Text(t,style:const TextStyle(fontWeight:FontWeight.w600)),Text(v,style:TextStyle(color:c,fontSize:17,fontWeight:FontWeight.bold))])));
 Widget mall()=>ListView(padding:const EdgeInsets.all(12),children:[const Text('Mall Ledger / مال کا حساب',style:TextStyle(fontSize:21,fontWeight:FontWeight.bold)),Wrap(spacing:8,children:['Purchase','Sale','Expense'].map((k)=>FilledButton(onPressed:()=>add(k),child:Text('Add $k'))).toList()),...entries.map((e)=>Card(child:ListTile(title:Text(e.kind),subtitle:Text('${e.date} • ${e.detail}'),trailing:Text(cash(e.amount)))) )]);
 Widget customers()=>ListView(padding:const EdgeInsets.all(12),children:[const Text('Customers / کسٹمرز',style:TextStyle(fontSize:21,fontWeight:FontWeight.bold)),Text('Customer credit total: ${cash(sum('Credit'))}'),FilledButton(onPressed:()=>add('Credit'),child:const Text('Add Customer Credit')),...entries.where((e)=>e.kind=='Credit').map((e)=>Card(child:ListTile(leading:const Icon(Icons.person,color:blue),title:Text(e.detail.isEmpty?'Customer':e.detail),subtitle:Text(e.date),trailing:Text(cash(e.amount)))))]);
 Widget reports()=>ListView(padding:const EdgeInsets.all(12),children:[const Text('Reports / رپورٹس',style:TextStyle(fontSize:21,fontWeight:FontWeight.bold)),row('Total Sale',sum('Sale')),row('Total Purchase',sum('Purchase')),row('Expenses',sum('Expense')),row('Net Profit / Loss',sum('Sale')-sum('Purchase')-sum('Expense')),const Card(child:Padding(padding:EdgeInsets.all(12),child:Text('Local totals are shown. PDF export and date-filtered reports are not in this starter build.')))]);
 Widget row(String t,double n)=>Card(child:ListTile(title:Text(t),trailing:Text(cash(n),style:const TextStyle(fontWeight:FontWeight.bold))));
 Widget settings()=>SettingsPage(name:shop,onSave:(v)async{final p=await SharedPreferences.getInstance();await p.setString('shop',v);if(mounted)setState(()=>shop=v);});
}
class SettingsPage extends StatefulWidget{final String name;final Future<void> Function(String) onSave;const SettingsPage({super.key,required this.name,required this.onSave});@override State<SettingsPage> createState()=>_SettingsPageState();}
class _SettingsPageState extends State<SettingsPage>{late TextEditingController c;@override void initState(){super.initState();c=TextEditingController(text:widget.name);}@override void dispose(){c.dispose();super.dispose();}
 @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(16),children:[const Text('Settings / دکان کی معلومات',style:TextStyle(fontSize:21,fontWeight:FontWeight.bold)),TextField(controller:c,decoration:const InputDecoration(labelText:'Shop Name',border:OutlineInputBorder())),const SizedBox(height:10),FilledButton(onPressed:()=>widget.onSave(c.text.trim()),child:const Text('Save Settings')),const Card(child:ListTile(leading:Icon(Icons.backup),title:Text('Backup & Restore'),subtitle:Text('Local storage is active; export/import not implemented yet.'))),const Card(child:ListTile(leading:Icon(Icons.key,color:red),title:Text('Demo / License'),subtitle:Text('Secure license validation needs separate implementation.'))),const Card(child:ListTile(leading:Icon(Icons.info),title:Text('About'),subtitle:Text('TU Chicken Zone • Version 1.0')))]);
}
