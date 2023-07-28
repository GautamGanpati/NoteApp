import 'package:flutter/material.dart';
import 'package:note/sql_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _notes = [];

  bool _isLoading = true;

  void _refreshNotes() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _notes = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  Future<void> _addItem() async {
    await SQLHelper.createItem(
        _titleController.text, _descriptionController.text);

    _refreshNotes();
    _titleController.clear();
    _descriptionController.clear();
  }

  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
        id, _titleController.text, _descriptionController.text);
    _refreshNotes();
    _titleController.clear();
    _descriptionController.clear();
  }

  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Deleted'),
      ),
    );
    _refreshNotes();
  }

  void _showForm(int? id) async {
    if (id != null) {
      final existingNote = _notes.firstWhere((element) => element['id'] == id);
      _titleController.text = existingNote['title'];
      _descriptionController.text = existingNote['description'];
    }

    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: context,
      builder: (_) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
              top: 15,
              left: 15,
              right: 15,
              bottom: MediaQuery.of(context).size.height / 3),
          //decoration: const BoxDecoration(border: Border.symmetric()),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                constraints: const BoxConstraints(
                  maxHeight: 150,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.black,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 10.0,
                    right: 10.0,
                  ),
                  child: TextField(
                    textAlignVertical: TextAlignVertical.center,
                    style: const TextStyle(fontSize: 18),
                    cursorColor: Colors.white,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Title',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                constraints: const BoxConstraints(
                  minHeight: 200,
                  maxHeight: 250,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.black,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 10.0,
                    right: 10.0,
                  ),
                  child: TextField(
                    style: const TextStyle(fontSize: 20),
                    cursorColor: Colors.white,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: 'Note',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.deepPurple,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                  ),
                  child: TextButton(
                    onPressed: () async {
                      if (id == null &&
                          _descriptionController.text.isNotEmpty) {
                        await _addItem();
                      }
                      if (id != null) {
                        await _updateItem(id);
                      }
                      _titleController.clear();
                      _descriptionController.clear();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      id == null ? 'Create New' : 'Update',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 26, 26, 26),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 12, 12, 12),
          elevation: 5,
          title: const Text(
            'Notes',
            style: TextStyle(
              fontSize: 22,
            ),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: () {
                _showForm(null);
              },
              icon: const Icon(
                Icons.add,
                size: 35,
              ),
            )
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: const Color.fromARGB(255, 12, 12, 12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      _showForm(_notes[index]['id']);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () =>
                                        _deleteItem(_notes[index]['id']),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      _notes[index]['title'],
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8, bottom: 30),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          _notes[index]['description'],
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.w400),
                                          maxLines: null,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    // ListTile(
                    //   tileColor: Color.fromARGB(255, 12, 12, 12),
                    //   title: Padding(
                    //     padding: const EdgeInsets.only(top: 25),
                    //     child: Container(
                    //       decoration: BoxDecoration(
                    //           border: Border.all(
                    //         width: 1,
                    //         color: Colors.white,
                    //       )),
                    //       child: Text(
                    //         _notes[index]['title'],
                    //         style: const TextStyle(
                    //             color: Colors.white,
                    //             fontSize: 20,
                    //             fontWeight: FontWeight.w300),
                    //       ),
                    //     ),
                    //   ),
                    //   subtitle: Padding(
                    //     padding: const EdgeInsets.only(top: 50),
                    //     child: Column(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         Container(
                    //           decoration: BoxDecoration(
                    //               border: Border.all(
                    //                   width: 1, color: Colors.white)),
                    //           child: Padding(
                    //             padding:
                    //                 const EdgeInsets.only(top: 15, bottom: 25),
                    //             child: Text(
                    //               _notes[index]['description'],
                    //               style: TextStyle(
                    //                   color: Colors.white,
                    //                   fontSize: 22,
                    //                   fontWeight: FontWeight.w400),
                    //               maxLines: null,
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    //   trailing: Container(
                    //     decoration: BoxDecoration(
                    //         border: Border.all(width: 1, color: Colors.white)),
                    //     child: SizedBox(
                    //       width: 100,
                    //       height: 100,
                    //       child: Row(
                    //         children: [
                    //           IconButton(
                    //             icon: const Icon(Icons.edit),
                    //             onPressed: () {
                    //               _showForm(_notes[index]['id']);
                    //             },
                    //           ),
                    //           IconButton(
                    //             icon: const Icon(Icons.delete),
                    //             onPressed: () =>
                    //                 _deleteItem(_notes[index]['id']),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  );
                }),
        // floatingActionButton: FloatingActionButton(
        //   elevation: 15,
        //   backgroundColor: Colors.green,
        //   onPressed: () {
        //     _showForm(null);
        //   },
        //   child: const Icon(Icons.add),
        // ),
      ),
    );
  }
}
