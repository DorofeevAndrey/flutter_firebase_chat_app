import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String title;
  final Function()? onTap;

  const UserTile({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            // icon
            Icon(Icons.person),
            SizedBox(width: 20),

            // user name
            Text(title),
          ],
        ),
      ),
    );
  }
}
