- Install Jupyter (Follow steps mentioned in jupyter_install.txt)

- Install lupa (Follow steps mentioned in build_install_lupa.txt)

- Install echo kernel (a wrapper kernel)
$ pip install echo_kernel
$ python -m echo_kernel.install

- Install Q
$ cd Q
$ bash q_install.sh

- Replace kernel file with modified copy
$ cp Q/experimental/jupyter/kernel.py /usr/local/lib/python2.7/dist-packages/echo_kernel/

- Start Jupyter notebook
$ jupyter notebook --allow-root --no-browser --port 9999 --ip 192.168.85.149

- Try below Q statements from notebook browser

c1 = Q.mk_col({1, 2, 4}, "I4")
assert(type(c1) == "lVector")
Q.print_csv(c1, nil, "")
return "Done"

return Q.print_csv(c1, nil, nil)
