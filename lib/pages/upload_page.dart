import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  bool isUploading = false;
  final SupabaseClient supabase = Supabase.instance.client;

  Future getMyFiles() async {
    final List<FileObject> result = await supabase.storage
        .from('user-images')
        .list(path: supabase.auth.currentUser!.id);
    List<Map<String, String>> myImages = [];
    for (var image in result) {
      final getUrl = supabase.storage
          .from('user-images')
          .getPublicUrl("${supabase.auth.currentUser!.id}/${image.name}");
      myImages.add({'name': image.name, 'url': getUrl});
    }
    return myImages;
  }

  Future<void> deleteImage(String imageName) async {
    try {
      await supabase.storage
          .from('user-images')
          .remove(["${supabase.auth.currentUser!.id}/$imageName"]);
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("something went wrong!")));
      log(e.toString());
    }
  }

  Future<void> uploadFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        isUploading = true;
      });
      try {
        final File file = File(result.files.single.path!);
        final String fileName = result.files.single.name;
        await supabase.storage
            .from('user-images')
            .upload("${supabase.auth.currentUser!.id}/$fileName", file);
        setState(() {
          isUploading = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("File upload successfully"),
          backgroundColor: Colors.greenAccent,
        ));
      } catch (e) {
        log("Error : $e");
        setState(() {
          isUploading = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("something went wrong!"),
          backgroundColor: Colors.redAccent,
        ));
      }
    } else {
      //user cancel the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('supabase storage'),
        ),
        body: FutureBuilder(
          future: getMyFiles(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.length == 0) {
                return const Center(
                  child: Text("no image available"),
                );
              }
              return ListView.separated(
                itemCount: snapshot.data.length,
                padding: const EdgeInsets.symmetric(vertical: 10),
                separatorBuilder: (context, index) {
                  return const Divider(
                    thickness: 2,
                    color: Colors.black,
                  );
                },
                itemBuilder: (context, index) {
                  Map imageData = snapshot.data[index];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 200,
                        width: 300,
                        child: Image.network(
                          imageData['url'],
                          fit: BoxFit.cover,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await deleteImage(imageData['name']);
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                      )
                    ],
                  );
                },
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
        floatingActionButton: isUploading
            ? const CircularProgressIndicator()
            : FloatingActionButton(
                onPressed: uploadFile,
                child: const Icon(Icons.add_a_photo),
              ));
  }
}
