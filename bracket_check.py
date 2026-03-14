import re
import sys

def check_brackets(file_path):
    with open(file_path, "r", encoding="utf-8") as f:
        text = f.read()

    lines = text.split("\n")
    stack = []
    
    pairs = {
        ')': '(',
        '}': '{',
        ']': '['
    }
    
    for i, line in enumerate(lines):
        line_num = i + 1
        for char in line:
            if char in "({[":
                stack.append((char, line_num))
            elif char in ")}]":
                if not stack:
                    print(f"Error on line {line_num}: Extra '{char}'")
                    return
                top_char, top_line = stack.pop()
                if pairs[char] != top_char:
                    print(f"Error on line {line_num}: Mismatched '{char}'. Expected '{pairs[char]}' to close '{top_char}' on line {top_line}")
                    return
                    
    if stack:
        print("Unclosed brackets:")
        for char, line in stack:
            print(f"  Line {line}: {char}")
    else:
        print("All brackets align correctly.")

if __name__ == "__main__":
    check_brackets("lib/chat_screen.dart")
