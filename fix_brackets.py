import os
import re

file_path = "lib/chat_screen.dart"

with open(file_path, "r", encoding="utf-8") as f:
    text = f.read()

# Let's count brackets to diagnose exactly what is missing
opens = text.count('{')
closes = text.count('}')

open_parens = text.count('(')
close_parens = text.count(')')

print(f"Braces open: {opens}, close: {closes}")
print(f"Parens open: {open_parens}, close: {close_parens}")

# We already know there's a widget closing sequence issue
# Let's just strip the broken end and replace it explicitly with correct closures.

end_sequence = """
            // Bottom Input Area
            Container(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
              color: Colors.white,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.image_outlined, color: Colors.grey.shade400),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.videocam_outlined, color: Colors.grey.shade400),
                      onPressed: () {},
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send_outlined, color: Colors.indigo.shade200),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
"""

index = text.find("// Bottom Input Area")
if index != -1:
    new_text = text[:index] + end_sequence.strip() + "\n"
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(new_text)
    print("Fixed ending applied.")
else:
    print("Could not find anchor point.")
