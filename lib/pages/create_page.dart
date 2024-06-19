import "dart:developer";

import "package:flutter/material.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  bool isLoading = false;
  TextEditingController titleController = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void dispose() {
    titleController.dispose();
    supabase.dispose();
    super.dispose();
  }

  Future insertData(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    try {
      String userId = supabase.auth.currentUser!.id;
      await supabase
          .from('todos')
          .insert({'title': titleController.text, 'user_id': userId});
      if (!context.mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      log("Error inserting data : $e");
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Something went wrong!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Data")),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                  hintText: "enter title", border: OutlineInputBorder()),
            ),
            const SizedBox(
              height: 10,
            ),
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : ElevatedButton(
                    onPressed: () async {
                      insertData(context);
                    },
                    child: const Text("create"))
          ],
        ),
      ),
    );
  }
}
