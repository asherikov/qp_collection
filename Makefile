qpoases_test_update:
	git fetch --all
	git rm --ignore-unmatch -rf qpoases_test/original
	rm -Rf qpoases_test/original
	git read-tree --prefix=qpoases_test/original -u c0fbef6f1726f906fbfc8ef110bb98a781bf561e
	git rm --ignore-unmatch -rf qpoases_test/original/binaries
	git rm --ignore-unmatch -rf qpoases_test/original/testingdata/matlab/

qpoases_test_convert:
	rm -Rf qpoases_test/json
	mkdir -p qpoases_test/json/oneshot
	mkdir -p qpoases_test/json/iterative
	cd qpoases_test; octave --no-history --silent converter.m
	find qpoases_test/json/ -iname "*.json" | xargs -I {} sed -i '' \
		-e 's/\[true\]/true/g' \
		-e 's/\[false\]/false/g' \
		-e 's/"value":\[\([-.e0-9]*\)\]/"value":\1/' {}

addremote:
	-git remote add qpoases_test https://github.com/coin-or/qpOASES --no-tags -t misc
