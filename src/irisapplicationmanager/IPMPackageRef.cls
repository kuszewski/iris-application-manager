Class irisapplicationmanager.IPMPackageRef Extends %RegisteredObject
{

/// Name of the package
Property Name As %String;

/// Version for the package
Property Version As %String;

/// Namespace the package is/should be installed into
Property Namespace As %String;

ClassMethod Create(name As %String, version As %String, namespace As %String) As irisapplicationmanager.IPMPackageRef
{
    s rv = ##class(irisapplicationmanager.IPMPackageRef).%New()
    s rv.Name = name
    s rv.Version = version
    s rv.Namespace = namespace

    return rv
}

Method Equal(comparitor, pIgnoreVersion As %Boolean = 0) As %Boolean
{
    if (..Name=comparitor.Name) && (..Namespace=comparitor.Namespace) {
        if (pIgnoreVersion) || (..Version=comparitor.Version) {
            return $$$OK
        }
    }
    return 0
}

}
