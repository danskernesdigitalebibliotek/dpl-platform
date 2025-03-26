#!/usr/bin/env zx

const projectName = $1;
if (!projectName) {
  throw Error("No 'projectName' provided");
}

console.log(`Reseting files from ${projectName}-main to ${projectName}-moduletest
  \n
  Will now delete all files and folder in '/app/web/sites/default/files'
  \n
`);

