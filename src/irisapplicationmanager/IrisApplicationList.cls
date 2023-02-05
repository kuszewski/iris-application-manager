/// Import and Synchronize an IrisApplicationList YAML.
/// * Includes a list of IrisApplications to make sure are installed
/// * Includes the description of an IrisApplication, which is just a list of IPM/ZPM packages to install
Class irisapplicationmanager.IrisApplicationList
{

Parameter TARGETFILEENVVAR = "ISC_IRIS_APPLICATIONS_FILE";

Parameter TARGETFILEDEFAULT = "../mgr/iris-applications.yaml";

/// Return the path to the Target
ClassMethod GetTargetFilepath() As %String
{
    // TODO - should you be able to set this via CPF?
    set rv = ##class(%SYSTEM.Util).GetEnviron(..#TARGETFILEENVVAR)
    if rv = "" {
        quit ..#TARGETFILEDEFAULT
    }
    quit rv
}

// Loads the IrisApplicationList YAML from the requested filepath.

ClassMethod LoadTargetList(filepath As %String) As %DynamicObject
{
    set a = ##class(irisapplicationmanager.YAML).ToDynObj(filepath)

    // TODO: Validate the YAML

    quit a
}

/* Makes sure that a requested package is installed in the IRIS instance  The input looks like this:

  - package: isc.codetidy:1.1.1
    irisNamespace: USER
*/
ClassMethod UpsertIPM(package As %DynamicObject)
{
    s packageInfo = $LISTFROMSTRING(package.package,":",0)

    // TODO - 
    //    validation of the namespace.  make sure it exists and you can edit it and so on?
    //    handle version ranges rather than requiring an exact version number  (for example foo:3.1 would work for any of 3.1.0, 3.1.2, or 3.1.300, but not 3.2 or 4.0)

    s ref = ##class(irisapplicationmanager.IPMPackageRef).Create($LIST(packageInfo,1), $LIST(packageInfo,2), package.irisNamespace)
    d ##class(irisapplicationmanager.IPM).UpsertPackage(ref)
}

/*
A package looks like this in the YAML:

  name: myApp1
  ipm:
    - package: isc.codetidy:1.1.1
      irisNamespace: USER
    - package: csvgen:1.4.1
      irisNamespace: USER
*/
ClassMethod SynchronizeApplication(application As %DynamicObject)
{
    // TODO:  This is minimalistic implementation that just synchronizes the IPM packages to install.
    //        Add a history stored in IRIS of the IrisApplications installed on the instance.
    //        This needs to know which IPM packages were installed as part of this application and delete them if no longer in use
    set iter = application.ipm.%GetIterator()
    while iter.%GetNext(.key, .value, .type ) {
        d ..UpsertIPM(value)
    }
}

/// Given a DynamicObject that's the IrisApplicationList, synchronize that with what's installed in IRIS
ClassMethod SynchronizeIrisApplicationList(targetList As %DynamicObject)
{
    // TODO:  This needs to keep track of installed applications as well as delete apps that are no longer wanted
    set iter = targetList.applications.%GetIterator()
    while iter.%GetNext(.key, .value, .type ) {
        d ..SynchronizeApplication(value)
    }
}

ClassMethod Synchronize(filepath As %String)
{
    d ..SynchronizeIrisApplicationList(..LoadTargetList(filepath))
}

}
