#!/usr/bin/env zx

import * as crypto from "crypto";

const project = `${process.argv[3]}`;
if (!project) {
  throw Error("No 'project' provided");
}

const environment = `${process.argv[4]}`;
if (!environment) {
  throw Error("No 'environment' provided");
}

let dryRun = `${process.argv[5]}`;
if (typeof `${process.argv[5]}` === "undefined") {
  dryRun = false;
}

const password = crypto.randomBytes(32).toString("base64");

