/// YAML parser/writer for InterSystems IRIS.
/// Convert YAML into %DynamicObject and vice versa.
/// Stolen from https://gist.github.com/eduard93/49267de2012eb634b1d0cc55938f4ee6
/// Requires ruamel.yaml
Class irisapplicationmanager.YAML
{

/// Entry point.
/// Before running this code the first time, execute: set sc = ##class(User.YAML).Install() 
/// do ##class(User.YAML).Test()
ClassMethod Test()
{

	// Load YAML string. 
	set yamlStr = ##class(%Dictionary.XDataDefinition).IDKEYOpen($classname(), "Sample").Data.Read($$$MaxStringLength)
	
	// Convert it to %DynamicObject (accepts string, stream, filename)
	set object = ..ToDynObj(yamlStr)
	
	// Add some properties
	set object.hello = "world!"
	
	// Write to disk
	set dir = ##class(%File).NormalizeDirectory(##class(%SYS.System).TempDirectory())
	set file = dir _ "test.yml"
	set sc = ..FromDynObj(object, file)
	
	// Add some more properties
	set object.hello2 = [ 1, 2, 3]
	
	// Get YAML as string
	set sc = ..FromDynObj(object, .string)

	// Output do device
	write string
}

/// Load YAML file as %DynamicObject
/// file - either a filename or a string or a stream
/// set obj = ##class(User.YAML).ToDynObj()
ClassMethod ToDynObj(file) As %DynamicObject
{
	set builtins = ##class(%SYS.Python).Import("builtins")
	set json = ##class(%SYS.Python).Import("json")
	set yaml = ##class(%SYS.Python).Import("ruamel.yaml").YAML()
	
	if ##class(%File).Exists(file) {
		set f = builtins.open(file)
		set dict = yaml.load(f)
		do f.close()
		kill f
	} else {
		if $isObject(file) {
			do file.Rewind()
			set dict = yaml.load(file.Read($$$MaxStringLength))
		} else {
			set dict = yaml.load(file)
		}
	}
	
	set jsonStr = json.dumps(dict)
	set obj = {}.%FromJSON(jsonStr)
	quit obj
}

/// Convert %DynamicObject into YAML
/// If file is:
///   - string: enterpreted as a filepath
///   - stream: appended to
///   - empty: assumed to be a variable passed by reference, would write YAML string into it
/// set sc = ##class(User.YAML).FromDynObj()
ClassMethod FromDynObj(object, file) As %Status
{
	#dim sc As %Status = $$$OK
	set builtins = ##class(%SYS.Python).Import("builtins")
	set json = ##class(%SYS.Python).Import("json")
	set yaml = ##class(%SYS.Python).Import("ruamel.yaml").YAML()
	
	// mapping=None, sequence=4, offset=2
	do yaml.indent(##class(%SYS.Python).None(), 4, 2)
	set dict = json.loads(object.%ToJSON())

	if $d(file) && '$isObject(file) {
		set f = builtins.open(file, "w")
		do yaml.dump(dict, f)
		do f.close()
		kill f
	} else {
		set io  = ##class(%SYS.Python).Import("io").StringIO("", $$$NL)
		do yaml.dump(dict,  io)
		set str = io.getvalue()
		do io.close()
		
		if $d(file) && $isObject(file)  {
			if file.%Extends(##class(%Stream.Object).%ClassName($$$YES)) {
				set sc = file.Write(str)				
			} else {
				set sc = $$$ERROR($$$GeneralError, "Expected stream. Received: " _ file.%ClassName($$$YES))
			}
		} else {
			set file = str
		}
	}

	quit sc
}

/// Simple YAML
XData Sample [ MimeType = application/yaml ]
{
doe: "a deer, a female deer"
ray: "a drop of golden sun"
pi: 3.14159
xmas: true
french-hens: 3
calling-birds:
  - huey
  - dewey
  - louie
  - fred
xmas-fifth-day:
  calling-birds: four
  french-hens: 3
  golden-rings: 5
  partridges:
    count: 1
    location: "a pear tree"
  turtle-doves: two
}

}
