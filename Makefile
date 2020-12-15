update_qpoases_test:
	git fetch --all
	git rm --ignore-unmatch -rf qpoases_test/original
	rm -Rf qpoases_test/original
	git read-tree --prefix=qpoases_test/original -u c0fbef6f1726f906fbfc8ef110bb98a781bf561e
	git rm --ignore-unmatch -rf qpoases_test/original/binaries

addremote:
	-git remote add qpoases_test https://github.com/coin-or/qpOASES --no-tags -t misc
