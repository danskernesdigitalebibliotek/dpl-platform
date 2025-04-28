#!/usr/bin/env zx


const project = `${process.argv[3]}`;
if (!project) {
  throw Error("No 'project' provided");
}

const environment = `${process.argv[4]}`;
if (!environment) {
  throw Error("No 'environment' provided");
}

