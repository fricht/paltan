import 'package:flutter/material.dart';


// snackbar builder to have it the same everywhere
void showSnackBar(BuildContext context, Widget content, SnackBarAction? action) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: color4,
      dismissDirection: DismissDirection.horizontal,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      behavior: SnackBarBehavior.floating,
      content: content,
      action: action,
    ),
  );
}


// https://coolors.co/palette/e6c229-f17105-d11149-6610f2
const Color color1 = Color.fromARGB(255, 230, 194, 41);
const Color color2 = Color.fromARGB(255, 241, 113, 5);
const Color color3 = Color.fromARGB(255, 209, 17, 73);
const Color color4 = Color.fromARGB(255, 102, 16, 242);


// button on the main menu
class MainButton extends StatelessWidget {
  final VoidCallback onPress;
  final String btnText;
  const MainButton({super.key, required this.onPress, required this.btnText});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 50,
      child: ElevatedButton(
        style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(color1),
            foregroundColor: WidgetStatePropertyAll(color4)
        ),
        onPressed: onPress,
        child: Text(btnText),
      ),
    );
  }
}

