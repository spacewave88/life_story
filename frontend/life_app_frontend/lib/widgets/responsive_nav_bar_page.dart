import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';

class ResponsiveNavBarPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final ScrollController scrollController;
  final String title;
  final Future<void> Function()? onLogout;
  final Widget body;
  final Widget? floatingActionButton;
  final bool hideAuthButtons;

  ResponsiveNavBarPage({
    Key? key,
    required this.scaffoldKey,
    required this.scrollController,
    required this.title,
    this.onLogout,
    required this.body,
    this.floatingActionButton,
    this.hideAuthButtons = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isLargeScreen = width > 800;
    final bool isUserLoggedIn = Provider.of<AuthProvider>(context).isUserLoggedIn;

    return Theme(
      data: ThemeData.light(),
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleSpacing: 0,
          leading: isLargeScreen
              ? null
              : IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => scaffoldKey.currentState?.openDrawer(),
                ),
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Logo",
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
                if (isLargeScreen) Expanded(child: _navBarItems(context, isUserLoggedIn))
              ],
            ),
          ),
          actions: [
            if (isUserLoggedIn)
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: CircleAvatar(child: _ProfileIcon(onLogout: onLogout)),
              ),
          ],
        ),
        drawer: _drawer(context, isUserLoggedIn),
        body: body,
        floatingActionButton: floatingActionButton,
      ),
    );
  }

  Widget _drawer(BuildContext context, bool isUserLoggedIn) => Drawer(
        child: ListView(
          children: [
            ..._menuItems.map(
              (item) => ListTile(
                onTap: () {
                  scaffoldKey.currentState?.openEndDrawer();
                },
                title: Text(item),
              ),
            ),
            if (!isUserLoggedIn && !hideAuthButtons)
              ListTile(
                onTap: () {
                  Navigator.pushNamed(context, '/login');
                },
                title: const Text('Sign In'),
              ),
          ],
        ),
      );

  Widget _navBarItems(BuildContext context, bool isUserLoggedIn) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ..._menuItems.map(
            (item) => InkWell(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 24.0, horizontal: 16),
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
          if (!isUserLoggedIn && !hideAuthButtons) ...[
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: const Text('Sign In'),
            ),
          ],
        ],
      );
}

final List<String> _menuItems = <String>[
  'About',
  'Contact',
  'Help',
];

enum Menu { itemOne, itemTwo, itemThree }

class _ProfileIcon extends StatelessWidget {
  final Future<void> Function()? onLogout;

  const _ProfileIcon({Key? key, this.onLogout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Menu>(
        icon: const Icon(Icons.person),
        offset: const Offset(0, 40),
        onSelected: (Menu item) async {
          if (item == Menu.itemThree && onLogout != null) {
            await onLogout!();
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/',
              (route) => false,
              arguments: 'You have successfully logged out',
            );
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
              const PopupMenuItem<Menu>(
                value: Menu.itemOne,
                child: Text('Account'),
              ),
              const PopupMenuItem<Menu>(
                value: Menu.itemTwo,
                child: Text('Settings'),
              ),
              const PopupMenuItem<Menu>(
                value: Menu.itemThree,
                child: Text('Sign Out'),
              ),
            ]);
  }
}