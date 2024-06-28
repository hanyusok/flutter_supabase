import 'package:flutter/material.dart';
import 'package:flutter_supabase/pages/create_page.dart';
import 'package:flutter_supabase/pages/edit_page.dart';
import 'package:flutter_supabase/pages/upload_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final SupabaseClient supabase = Supabase.instance.client;
  late Stream<List<Map<String, dynamic>>> _readStream;
  int _selectedIndex = 0;

  @override
  void initState() {
    _readStream = supabase
        .from('todos')
        .stream(primaryKey: ['id'])
        .eq('user_id', supabase.auth.currentUser!.id)
        .order('id', ascending: false);
    super.initState();
  }

  Future<List> readData() async {
    final result = await supabase
        .from('todos')
        .select()
        .eq('user_id', supabase.auth.currentUser!.id)
        .order('id', ascending: false);
    return result;
  }

/* bottom Navigation settting*/
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("todo 리스트"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UploadPage()));
              },
              icon: const Icon(Icons.upload_file)),
          IconButton(
              onPressed: () async {
                await supabase.auth.signOut();
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: StreamBuilder(
          stream: _readStream,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }
            if (snapshot.hasData) {
              if (snapshot.data.length == 0) {
                return const Center(
                  child: Text("No data available"),
                );
              }
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, int index) {
                  var data = snapshot.data[index];
                  return ListTile(
                    leading: const Icon(Icons.task_alt),
                    title: Text(data['title']),
                    subtitle: Text(data['memo']),
                    trailing: IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditPage(
                                    data['title'], data['memo'], data['id'])));
                      },
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.red,
                      ),
                    ),
                  );
                },
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const CreatePage()));
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Business',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'School',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
