#!/bin/bash

if [[ $TRAVIS_OS_NAME == "osx" ]] && [[ $COMPILER == "gcc" ]]; then
    export CXX=g++-8
    export CC=gcc-8
elif [[ $TRAVIS_OS_NAME == "linux" ]] && [[ $COMPILER == "clang" ]]; then
    export CXX=clang++
    export CC=clang
fi

conda create -q -n test-env python=$PYTHON_VERSION
source activate test-env

cd $TRAVIS_BUILD_DIR

conda install numpy nose scipy scikit-learn pandas matplotlib python-graphviz pytest

mkdir $TRAVIS_BUILD_DIR/build && cd $TRAVIS_BUILD_DIR/build

cmake -DUSE_SWIG=ON ..
make || exit -1

cd $TRAVIS_BUILD_DIR/build/com/microsoft/ml/lightgbm/linux/x86_64
ls -l

cd $TRAVIS_BUILD_DIR/python-package && python setup.py install --precompile || exit -1
pytest $TRAVIS_BUILD_DIR || exit -1

if [[ $TASK == "regular" ]]; then
    cd $TRAVIS_BUILD_DIR/examples/python-guide
    sed -i'.bak' '/import lightgbm as lgb/a\
import matplotlib\
matplotlib.use\(\"Agg\"\)\
' plot_example.py  # prevent interactive window mode
    for f in *.py; do python $f || exit -1; done  # run all examples
fi
