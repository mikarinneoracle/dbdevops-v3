#!/bin/bash

cd ../dbdevops
git rm -f *.xml
git rm -rf index
git rm -rf package_spec
git rm -rf procedure
git rm -rf sequence
git rm -rf trigger
git rm -rf comment
git rm -rf package_body
git rm -rf ref_constraint
git rm -rf table
git rm -rf view
git status
cd ../scripts