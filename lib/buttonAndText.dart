// A stateful widget that combines a button and a text display
import 'package:flutter/material.dart';

class ButtonAndText extends StatefulWidget {
  const ButtonAndText({
      Key? key,
      required this.defaultText,
      required this.onPressed,
      required this.buttonText,
  }) : super(key: key);

  // The default text to display
  final String defaultText;
  // The text to display on the button
  final String buttonText;
  // The function to call when the button is pressed
  final Future<String> Function() onPressed;

  @override
  State<ButtonAndText> createState() => _ButtonAndTextState();
}

class _ButtonAndTextState extends State<ButtonAndText> {
  // The text to display, initially null
  String? _text;

  @override
  void didUpdateWidget(covariant ButtonAndText oldWidget) {
      super.didUpdateWidget(oldWidget);
      // Update the text if the default text changes
      if (widget.defaultText != oldWidget.defaultText) {
          setState(() {
            _text = widget.defaultText;
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Display the text
          Expanded(
            child: Text(
                _text ?? widget.defaultText,
                style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(width: 16),
          // Display the button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
            ),
            onPressed: () async {
                // Call the onPressed function and update the text with the result
                final result = await widget.onPressed();
                setState(() {
                  _text = result;
                });
            },
            child: Text(widget.buttonText),
          ),
        ],
      ),
    );
  }
}
