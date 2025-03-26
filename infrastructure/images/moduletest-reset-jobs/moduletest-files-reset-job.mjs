#!/usr/bin/env zx

const projectName = $1;
if (!projectName) {
  throw Error("No 'projectName' provided");
}

