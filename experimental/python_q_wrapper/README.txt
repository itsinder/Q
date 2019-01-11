Installations required for Python Q wrapper:

$ sudo apt-get install python-dev
$ sudo pip install lupa


Before running any test, run below command
$ source python_q_wrapper/to_source


To run tests:
$ python test_print_csv.py


Note:
>> If you face error while loading any module, please check whether __init__.py is present at below location
Q/__init__.py
Q/src/__init__.py

if not, please check it out
