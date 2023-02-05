# IRIS Application Manager

This is a thought experiment that starts to put a framework around two questions:

1. What defines an application in IRIS?
2. Can we define an idempotent structure to install applications into an IRIS instance?

Feel free to send comments, PRs, bug reports, etc.  Any feedback that attempts to answer the questions above is greatly appreciated.

Do not use this code for production.  That'd be crazy.

# What's this all about?

At the core of this library is the `iris-applications.yaml` file.  This file describes applications that should be installed on this IRIS instance.  This file is being actively worked on and is very simple for now. 

```yaml
apiVersion: intersystems.com/v1
kind: IrisApplicationList
applications:
  - name: firstApplication
    ipm:
      - package: zpmPackageName:version
        irisNamespace: namespace
      - package: zpmPackageName:version
        irisNamespace: namespace
      ...
  - name: secondApplication
    ...
```

This covers the idea that an IrisApplication can container ZPM/IPM packages that are installed in a namespace. Other concepts might need to be added.  I'm looking for feedback on what you would want to see added.

There's an example `iris-applications.yaml` file included in the repo so you can experiment with the concept.

# Usage

The full path to the iris-applications.yaml file should be specified in the `ISC_IRIS_APPLICATIONS_FILE` environment variable.  The dockerfile specifies this as an example.

To make sure that app the applications in your iris-applications.yaml file is installed in your IRIS instance, run the following:

```
do ##class(irisapplicationmanager.IrisApplicationList).Synchronize(##class(irisapplicationmanager.IrisApplicationList).GetTargetFilepath())
```

Uncomment the lines in iris.script if you want this done at container build time

if you want to use your own file, just pass that 

```
do ##class(irisapplicationmanager.IrisApplicationList).Synchronize("/path/to/iris-applications.yaml")
```


## Quickstart

You can just run this in docker with the usual tricks.

`docker run --rm -it $(docker build -q .)`

I might create a ZPM package out of this code, too.

## The IrisApplicationList API

API is a very strong word for what this is at the moment.

* `IrisApplicationList.cls` - This file represents the API for managing the `iris-applications.yaml` file.  You want to start here
* `IPMPackageRef.cls` - A simple data structure that represents a reference to an ZPM/IPM package.
* `IPM.cls` - A wrapper around the ZPM library that supports basic idempotent APIs.  ZPM/IPM itself probably has APIs like these somewhere, but I can't find them.
* `Yaml.cls` - A neet yaml-to-DynamicObject library from Eduard.
