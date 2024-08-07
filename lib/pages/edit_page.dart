import "package:flutter/material.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class EditPage extends StatefulWidget {
  final String editTitle;
  final String editMemo;
  final int editId;
  const EditPage(this.editTitle, this.editMemo, this.editId, {super.key});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  bool isLoading = false;
  TextEditingController titleController = TextEditingController();
  TextEditingController memoController = TextEditingController();
  SupabaseClient supabase = Supabase.instance.client;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> updateData() async {
    if (titleController.text != '') {
      setState(() {
        isLoading = true;
      });

      try {
        await supabase.from('todos').update({
          'title': titleController.text,
          'memo': memoController.text
        }).match({'id': widget.editId});
        // Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        Navigator.pop(context);
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Something went wrong!!")));
      }
    }
  }

  Future<void> deleteData() async {
    setState(() {
      isLoading = true;
    });

    try {
      await supabase.from('todos').delete().match({'id': widget.editId});
      // Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Something went wrong!!")));
    }
  }

  @override
  void initState() {
    titleController.text = widget.editTitle;
    memoController.text = widget.editMemo;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Data")),
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
            TextField(
              controller: memoController,
              decoration: const InputDecoration(
                  hintText: "enter memo", border: OutlineInputBorder()),
            ),
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: updateData,
                          child: const Text("Update"),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Divider(),
                      ElevatedButton.icon(
                        onPressed: deleteData,
                        icon: const Icon(Icons.delete),
                        label: const Text("Delete"),
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(Colors.red),
                        ),
                      )
                    ],
                  )
          ],
        ),
      ),
    );
  }
}
