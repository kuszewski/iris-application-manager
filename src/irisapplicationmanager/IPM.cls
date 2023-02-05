/// Wrapper around ZPM/IPM Package Manager (%ZPM.PackageManager)
///   Provides Idempotent API ZPM/IPM for use with the irisapplicationmanager
/// This library uses exceptions for error handling
Class irisapplicationmanager.IPM
{

/// Get the list of installed packages in a namespace
ClassMethod InstalledPackages(targetNamespace As %String) As %ListOfObjects(ELEMENTTYPE="irisapplicationmanager.IPMPackageRef")
{
    // TODO - after .list is "extra fields" - figure out what's available and get anything that might be important
    d ##class(%ZPM.PackageManager).GetListModules(targetNamespace,,.currentList)

    set rv = ##class(%ListOfObjects).%New()

    // currentList is a "classic" IRIS array.  Convert this to a %List so it can be returned and understood more easily
    for i = 1:1:currentList
    {
        s j = currentList(i)
        s name = $LIST(j,1)
        s installedVersion = $LIST(j,2)

        s item = ##class(irisapplicationmanager.IPMPackageRef).Create(name, installedVersion, targetNamespace)
        d rv.Insert(item)
    }

	quit rv
}

/// returns true if targetPackageRef (as irisapplicationmanager.IPMPackageRef) is installed
ClassMethod IsInstalled(targetPackageRef As irisapplicationmanager.IPMPackageRef, pIgnoreVersion As %Boolean = 0) As %Boolean
{
    // TODO:  Is this method needed?
    s installedPackages = ..InstalledPackages(targetPackageRef.Namespace)

    set rv = 0
    for i = 1:1:installedPackages.Count() {
        if installedPackages.GetAt(i).Equal(targetPackageRef, pIgnoreVersion) {
            return $$$OK
        }
    }

	return rv
}

/// returns irisapplicationmanager.IPMPackageRef of a package with the same name & namespace as the targetPackageRef
ClassMethod FindAnyVersion(targetPackageRef As irisapplicationmanager.IPMPackageRef) As irisapplicationmanager.IPMPackageRef
{
    s installedPackages = ..InstalledPackages(targetPackageRef.Namespace)

    for i = 1:1:installedPackages.Count() {
        if installedPackages.GetAt(i).Equal(targetPackageRef, 1) {
            return installedPackages.GetAt(i)
        }
    }

	return ""
}

/// Install a package
ClassMethod InstallPackage(targetPackageRef As irisapplicationmanager.IPMPackageRef)
{
    // TODO:  Check if there is a Namespace parameter that can be set in the commandInfo
    set ns =$NAMESPACE
    zn targetPackageRef.Namespace

    Set pCommandInfo("parameters","module")=targetPackageRef.Name
    Set pCommandInfo("parameters","version")=targetPackageRef.Version

    d ##class(%ZPM.PackageManager).Install(.pCommandInfo)

    zn ns
    quit
}

/// Uninstall a package
ClassMethod UninstallPackage(targetPackageRef As irisapplicationmanager.IPMPackageRef)
{
    set ns =$NAMESPACE
    zn targetPackageRef.Namespace

    Set pCommandInfo("parameters","module")=targetPackageRef.Name
    Set pCommandInfo("parameters","version")=targetPackageRef.Version

    d ##class(%ZPM.PackageManager).Uninstall(.pCommandInfo)

    zn ns
	quit
}

ClassMethod UpsertPackage(targetPackageRef As irisapplicationmanager.IPMPackageRef)
{
    set currentPackageRef = ..FindAnyVersion(targetPackageRef)

    if (currentPackageRef = "") {
        w !,!,"Installing Package "_targetPackageRef.Name_" version "_targetPackageRef.Version,!
        d ..InstallPackage(targetPackageRef)
    } else {
        if (currentPackageRef.Version = targetPackageRef.Version) {
            w !,!,targetPackageRef.Name_" version "_targetPackageRef.Version_" Already installed... skipping",!
        } else {
            // TODO - It looks like reinstall doesn't let you specify a specific version to upgrade to. So workaround it via uninstall/install
            w !,!,"Upgrading Package "_targetPackageRef.Name_" from "_currentPackageRef.Version_" to "_targetPackageRef.Version,!
            d ..UninstallPackage(currentPackageRef)
            d ..InstallPackage(targetPackageRef)
        }
    }
    quit
}

}
