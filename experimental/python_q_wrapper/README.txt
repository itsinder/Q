Installations required for Python Q wrapper:

$ sudo apt-get install python-dev
$ sudo pip install lupa

To run tests:
$ python test_print_csv.py


Note:
>> If you face error while running:
$ python test_print_csv.py 

Traceback (most recent call last):
  File "test_print_csv.py", line 1, in <module>
    import Q
ImportError: No module named Q

>> Please checkout Q/__init__.py which might have been deleted.

