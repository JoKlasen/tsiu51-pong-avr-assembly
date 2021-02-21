#!/bin/bash

git log > loggbok.txt

sed -i '/^commit/d' loggbok.txt
