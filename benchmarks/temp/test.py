# Test Python file for LSP benchmark
import sys
import os
from typing import List, Dict, Optional

class TestClass:
    def __init__(self, name: str):
        self.name = name
        self.items: List[str] = []
    
    def add_item(self, item: str) -> None:
        """Add an item to the collection."""
        self.items.append(item)
    
    def get_items(self) -> List[str]:
        """Return all items."""
        return self.items.copy()

def main():
    test = TestClass("example")
    for i in range(100):
        test.add_item(f"item_{i}")
    print(f"Added {len(test.get_items())} items")

if __name__ == "__main__":
    main()
