# tests/test_main.py

import unittest
from main import greet

class TestGreeting(unittest.TestCase):

    def test_greet(self):
        result = greet("John")
        self.assertEqual(result, "Hello, John!")

if __name__ == '__main__':
    unittest.main()
