import 'package:flutter/material.dart';
import 'package:flutter_acs/tree.dart';
import 'package:flutter_acs/requests.dart';
import 'dart:async';


class ScreenSpace extends StatefulWidget {
  final String id;
  const ScreenSpace({super.key, required this.id});

  @override
  State<ScreenSpace> createState() => _ScreenSpaceState();
}

class _ScreenSpaceState extends State<ScreenSpace> {
  late Future<Tree> futureTree;
  bool requestInProgress = false;

  @override
  void initState() {
    super.initState();
    futureTree = getTree(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Tree>(
      future: futureTree,
      builder: (context, snapshot) {
        // anonymous function
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              title: Text(snapshot.data!.root.id),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.home),
                  onPressed: _goToHomePage,
                ),
                //TODO other actions
              ],
            ),
            body: ListView.separated(
              // it's like ListView.builder() but better because it includes a separator between items
              padding: const EdgeInsets.all(16.0),
              itemCount: snapshot.data!.root.children.length,
              itemBuilder: (BuildContext context, int i) =>
                  _buildRow(snapshot.data!.root.children[i], i),
              separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
            ),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        // By default, show a progress indicator
        return Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: Center(
              child: CircularProgressIndicator(),
            ));
      },
    );
  }
  Widget _buildRow(Door door, int index) {
    return ListTile(
      title: Text('${door.id}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              if (door.state == 'locked') {
                unlockDoor(door);
              } else {
                lockDoor(door);
              }
              futureTree = getTree(widget.id);
              setState(() {});
            },
            icon: door.state == 'locked'
                ? Icon(Icons.lock)
                : Icon(Icons.lock_open),
          ),
          SizedBox(width: 8.0), // Adjust the spacing between icons
          IconButton(
            onPressed: () {
              if (door.closed== true){
                openDoor(door);
              } else {
                closeDoor(door);
              }
              futureTree = getTree(widget.id);
              setState(() {});
            },
            icon: door.closed ? Icon(Icons.door_front_door_outlined, color: Colors.red) : Icon(Icons.door_front_door_outlined, color: Colors.green),
          ),
        ],
      ),
    );
  }
  void _goToHomePage() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
