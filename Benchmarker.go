/*	Reads data from BenchmarkData.dat (five rows per language, first is name, second is compile command or "-" if interpreted, third is run command, fourth is source file name, fifth is executable name).
	Creates backups of the source file of each language, or loads it from the backup if a backup already exists.
	Modifies the number '444' in each source file, to alter the total array length.
	Compiles the languages, recording compile time and the size of the executable generated. 
	Runs them, recording their resident memory usage and the size.
	Restores the original source file.
	Waits WaitTime seconds between each run.
	Outputs their speed, memory usage and compile time to stdout.
	Compresses their source files and records their size.
	Sorts the languages, removing those that didn't run correctly.
	Calculates summary statistics.
	Outputs all the above data to an HTML table in ResultsTable.html
	Deletes the backups.
*/

package main

import (
	"bytes"
	"fmt"
	"errors"
	"io/ioutil"
	"os/exec"
	"sort"
	"strconv"
	"strings"
	"text/template"
	"time"
	"unicode"
)

const (
	langFile  = "BenchmarkData2.dat"
	outputFile = "ResultsTable2.html"
	WaitTime  = 15
)

var (
//	numTradesValuesToTest []string = []string{ "150", "100", "50", "10"}
	numTradesValuesToTest []string = []string{"150"}
)

type Lang struct {
	Name        string
	Commands    string
	Run         string
	SourceName  string
	ExeName     string
	CmplTime    float64
	Results     string
	Loaded      bool
	Interpreted bool
	RunTimes    []int
	BestRun	    int
	PcntBestTime  float64
	Compiler    string
	MemUse      int64
	CompSize    int64
	LOC         int
	NumChars    int
	ExeSize     int
}

func loadLangs()[]Lang {
	langs := make([]Lang,0,20)
	contents, err := ioutil.ReadFile(langFile)
	if err != nil {
		panic(err)
	}
	dataLines := strings.Split(string(contents), "\n")
	for i, _ := range dataLines {
		dataLines[i] = strings.Trim(dataLines[i], "\n\r")
	}
	for i := 0; i < len(dataLines)-1; i += 5 {
		thisLang := Lang{Name: dataLines[i], Commands: dataLines[i+1], Run: dataLines[i+2], SourceName: dataLines[i+3], ExeName: dataLines[i+4], Loaded: true, Interpreted: dataLines[i+1] == "-"}
		langs = append(langs, thisLang)
	}
	return langs
}


func modifyNumTrades(lang Lang, newVal string) error{
	fmt.Printf("Now modifying numTrades for language %v.\n", lang.Name)
	langSource, err := ioutil.ReadFile(lang.SourceName)
	if err != nil {
		fmt.Printf("Error loading source to modify numTrades for lang %v; failed with error of %v\n", lang.Name, err)
		return errors.New("Failed to modify numTrades")
	}
	sourceString := string(langSource)
	newSource := strings.Replace(sourceString, "444", newVal, 1)
	err = ioutil.WriteFile(lang.SourceName, []byte(newSource), 0644)
	if err != nil {
		fmt.Printf("Error writing new source to modify numTrades for lang %v; failed with error of %v\n", lang.Name, err)
		return errors.New("Failed to modify numTrades")
	}
	return nil
}

func restoreNumTrades(lang Lang) error{
	fmt.Printf("Now restoring numTrades for language %v.\n", lang.Name)
	_, err := runCommand("cp "+ lang.SourceName + ".bck " + lang.SourceName)
	if err != nil {
		fmt.Printf("Error copying original source back to restore numTrades for lang %v; failed with error of %v\n", lang.Name, err)
		return errors.New("Failed to restore numTrades")
	}
	return nil	
}

func deleteLangBackups(langs []Lang){
	for _, lang := range langs{
		_, err := runCommand("rm "+ lang.SourceName + ".bck")
		if err != nil {
			fmt.Printf("Error deleting backup source for lang %v; failed with error of %v\n", lang.Name, err)
		}
	}
}

func backupLangs(langs []Lang) []Lang{
	fmt.Println("Now backing up language sources.")
	for i, lang := range langs {
		_, doesntAlreadyExist := ioutil.ReadFile(lang.SourceName + ".bck")
		if (doesntAlreadyExist == nil){
			fmt.Printf("Backup already exists for language %v; loading that.\n", lang.Name)
			restoreNumTrades(lang)
			continue
		}
		_, err := runCommand("cp "+ lang.SourceName + " " + lang.SourceName + ".bck")
		if err != nil {
			fmt.Printf("Error copying original source to make backup before for lang %v; failed with error of %v\n", lang.Name, err)
			langs[i].Loaded = false
		}	
	}
	return langs
}

func compileNModifyLangs(langs []Lang, newNumTradesValue string)[]Lang {
	langs = backupLangs(langs)	
	for i, lang := range langs {
		if lang.Loaded == false {
			continue
		}
		err :=	modifyNumTrades(lang, newNumTradesValue)
		if err != nil{
			continue
		}
		if lang.Interpreted == true {
			continue
		}
		fmt.Printf("Now compiling language %v.\n", lang.Name)
		initT := time.Now()
		_, err = runCommand(lang.Commands)
		if err != nil {
			fmt.Printf("Compilation of %v failed with error of %v\n", lang.Name, err)
			langs[i].Loaded = false
		}
		endT := time.Now()
		langs[i].CmplTime = endT.Sub(initT).Seconds()
	}
	return langs
}

func runLangs(langs []Lang)[]Lang {
	for i, lang := range langs {
		if lang.Loaded == false {
			continue
		}
		fmt.Println("Pausing to allow the system to cool down.")
		time.Sleep(WaitTime * time.Second)
		fmt.Printf("Now running language %v.\n", lang.Name)
		prefix := ""
		if lang.Name == "Clojure"{
			prefix = "cd cjmt && "
		}
		out, err := runCommand(prefix + `command time -f 'max resident:\t%M KiB' ` + lang.Run)
		if err != nil {
			fmt.Printf("Running %v failed with error of %v\n", lang.Name, err)
			langs[i].Loaded = false
		}

		langs[i].Results = string(out)
		restoreNumTrades(lang)		
		if lang.Interpreted == true{
			continue
		}
		resultingExecutable, err := ioutil.ReadFile(lang.ExeName)
		if err != nil {
			fmt.Printf("Error of: %v when opening executable file for language %v, unable to measure size.\n", err, lang.Name)
			continue
		}
		langs[i].ExeSize = len(resultingExecutable) / 1000
	}
	return langs
}

func parseResults(langs []Lang)[]Lang {
	for i, lang := range langs {
		if lang.Loaded == false {
			continue
		}
		var memUse string
		numDurations := strings.Count(lang.Results, "duration")
		numMs := strings.Count(lang.Results, "ms")
		resultsCopy := lang.Results
		if numMs != numDurations{
			fmt.Printf("Failed to read running time results for language %v\n", lang.Name)
		} else {
			for ii:=0; ii< numMs; ii++{
				thisSpeed := resultsCopy[strings.Index(resultsCopy, "duration") + 8: strings.Index(resultsCopy, "ms")]
				thisSpeed = strings.TrimSpace(thisSpeed)
				speedInt64,err := strconv.ParseInt(thisSpeed, 10, 32)
				speedInt := int(speedInt64)
				resultsCopy = resultsCopy[strings.Index(resultsCopy, "ms")+2:]
				if err != nil{
					fmt.Printf("Failed to parse a running time string to an int for language %v.\n", lang.Name)
					continue
				}
				langs[i].RunTimes = append(langs[i].RunTimes, speedInt)
			}
		}
		minTime := 100000000
		for _, time := range langs[i].RunTimes{
			if time < minTime{
				minTime = time
			} 
		}		
		langs[i].BestRun = minTime		
		
		if strings.Index(lang.Results, "resident:") < 0 || strings.Index(lang.Results, "KiB") < 0 {
			fmt.Printf("Failed to read memory usage results for language %v\n", lang.Name)
			memUse = "N/A"
		} else {
			tmpStr := strings.TrimSpace(lang.Results[strings.Index(lang.Results, "resident:"):])
			memUse = tmpStr[strings.Index(tmpStr, "resident:")+9 : strings.Index(tmpStr, "KiB")]
			memUse = strings.TrimFunc(memUse, func(r rune) bool { return !unicode.IsDigit(r) })
			var err error
			langs[i].MemUse, err = strconv.ParseInt(memUse, 10, 32)
			if err != nil {
				fmt.Printf("Error parsing memory use to integer for language %v\n", lang.Name)
			}
		}
		fmt.Printf("The implementation in language %v compiled in %v seconds and ran at a maximum speed of %v ms, using %v KiB of heap memory.\n", lang.Name, lang.CmplTime, langs[i].BestRun, memUse)
	}
	return langs
}

func measureLangSizes(langs []Lang)[]Lang {
	fmt.Println("Now measuring compressed source file sizes and source file LOCs.")
	for i, lang := range langs {
		if lang.Loaded == false {
			continue
		}
		runCommand("bzip2 -k " + lang.SourceName)
		size, err := runCommand("du -b " + lang.SourceName + ".bz2")
		if err != nil {
			fmt.Printf("Error of: %v when reading compressed source file size for language %v\n", err, lang.Name)
			continue
		}
		intSize, err := strconv.ParseInt(strings.TrimSpace(size[:len(size)-len(lang.SourceName+".bz2")-1]), 10, 32)
		if err != nil {
			fmt.Printf("Error of: %v when parsing compressed source file size to int for language %v\n", err, lang.Name)
			continue
		}
		langs[i].CompSize = intSize
		_, _ = runCommand("rm " + lang.SourceName + ".bz2")

		sourceBytes, err := ioutil.ReadFile(lang.SourceName)
		if err != nil {
			fmt.Printf("Error of: %v when reading source file content for language %v, unable to count lines and characters.\n", err, lang.Name)
			continue
		}
		sourceString := string(sourceBytes)
		langs[i].NumChars = len(sourceString)
		sourceLines := (strings.Split(sourceString, "\n"))
		numEmptyLines := 0
		for _, ln := range sourceLines {
			if strings.TrimSpace(ln) == "" {
				numEmptyLines += 1
			}
		}
		langs[i].LOC = len(sourceLines) - numEmptyLines
	}
	return langs
}

func calcLangStats(langs []Lang)[]Lang {
	fmt.Println("Now calculating summary statistics")
	minTime := 100000000
	for _, lang := range langs {
		if lang.Loaded == false {
			continue
		}
		if lang.BestRun < minTime && lang.BestRun > 0 {
			minTime = lang.BestRun
		}
	}
	for i, lang := range langs {
		if lang.Loaded == false {
			continue
		}
		langs[i].PcntBestTime = float64(minTime)/ float64(lang.BestRun) * 100
		langs[i].Compiler = strings.Split(lang.Commands, " ")[0]
	}
	return langs
}

type BySpeed []Lang
func (s BySpeed) Len() int           { return len(s) }
func (s BySpeed) Swap(i, j int)      { s[i], s[j] = s[j], s[i] }
func (s BySpeed) Less(i, j int) bool { return s[i].BestRun < s[j].BestRun }

func sortLangs(langs []Lang)[]Lang{
	doneLangs := make([]Lang,0,len(langs))
	for _, lang := range langs{
		if lang.Loaded && lang.BestRun != 0{
			doneLangs = append(doneLangs, lang)
		}
	}
	sort.Sort(BySpeed(doneLangs))
	return doneLangs
}

func putResultsInHtmlTable(langs []Lang, numTrades string, tableString *string) {
	tmpl, err := template.New("row").Parse(`
		<tr>
		<td style="text-align: center;" width="81" height="17"><span style="color: #000000;"><em>{{.Name}}</em></span></td>
		<td style="text-align: center;" width="81"><span style="color: #000000;"><em>{{.Compiler}}</em></span></td>
		<td style="text-align: center;" width="81"><span style="color: #000000;"><em>{{printf "%.4f" .CmplTime}}</em></span></td>
		<td style="text-align: center;" width="81"><span style="color: #000000;"><em>{{printf "%d" .BestRun}}</em></span></td>
		<td style="text-align: center;" width="81"><span style="color: #000000;"><em>{{printf "%.2f" .PcntBestTime}}</em></span></td>
		<td style="text-align: center;" width="70"><span style="color: #000000;"><em>{{.MemUse}}</em></span></td>
		<td style="text-align: center;" width="70"><span style="color: #000000;"><em>{{.CompSize}}</em></span></td>
		<td style="text-align: center;" width="70"><span style="color: #000000;"><em>{{.LOC}}</em></span></td>
		<td style="text-align: center;" width="70"><span style="color: #000000;"><em>{{.NumChars}}</em></span></td>
		<td style="text-align: center;" width="70"><span style="color: #000000;"><em>{{.ExeSize}}</em></span></td>
		</tr>
	`)
	if err != nil{
		fmt.Println("Error parsing html table template; modify the source!")
		return
	}
	table := `
		<table width="394" border="1" cellspacing="1" cellpadding="1">
		<colgroup>
			<col span="4" width="81" />
			<col width="70" />
		</colgroup>
		<tbody>
			<tr>
			<td style="text-align: center;" width="81" height="17"><span style="color: #000000;"><em>Language</em></span></td>
			<td style="text-align: center;" width="81"><span style="color: #000000;"><em>Compiler</em></span></td>
			<td style="text-align: center;" width="81"><span style="color: #000000;"><em>Compile time (s)</em></span></td>
			<td style="text-align: center;" width="81"><span style="color: #000000;"><em>Running time (ms)</em></span></td>
			<td style="text-align: center;" width="81"><span style="color: #000000;"><em>% Fastest</em></span></td>
			<td style="text-align: center;" width="70"><span style="color: #000000;"><em>Resident mem use (KiB)</em></span></td>
			<td style="text-align: center;" width="70"><span style="color: #000000;"><em>Compressed source size</em></span></td>
			<td style="text-align: center;" width="70"><span style="color: #000000;"><em>Lines of code</em></span></td>
			<td style="text-align: center;" width="70"><span style="color: #000000;"><em>Number of characters</em></span></td>
			<td style="text-align: center;" width="70"><span style="color: #000000;"><em>Executable size (KB)</em></span></td>
			</tr>
	`
	for _, lang := range langs {
		if lang.Loaded == false {
			continue
		}
		var execResults bytes.Buffer
		err = tmpl.Execute(&execResults, lang)
		table += execResults.String()
	}
	table = "<b>NumTrades = " + numTrades + "</b><br>" +  
		table + `
		</tbody>
		</table>
		<br>`
	*tableString += table
	deleteLangBackups(langs)
}

func runCommand(command string) (string, error) {
	script := "#!/bin/bash\n" + command
	err := ioutil.WriteFile("command.sh", []byte(script), 0644)
	if err != nil {
		fmt.Printf("Failed to write command %v, with error: %v\n", command, err)
		return "", err
	}
	cmdOutput, err2 := exec.Command("sh", "command.sh").CombinedOutput()
	if err2 != nil {
		fmt.Printf("Failed to exec command %v, failing with error %v: %v\n", command, err2, string(cmdOutput))
		return "", err2
	}
	return string(cmdOutput), nil
}

func main() {
	htmlTables := ""
	for _, numTradesValue := range numTradesValuesToTest{
		fmt.Printf("Now commencing run with NumTrades value of %v\n",numTradesValue)
		putResultsInHtmlTable(calcLangStats(sortLangs(measureLangSizes(parseResults(runLangs(compileNModifyLangs(loadLangs(),numTradesValue)))))),numTradesValue,&htmlTables)
	}
	err := ioutil.WriteFile(outputFile, []byte(htmlTables), 0644)
	if err != nil {
		fmt.Printf("Failed to write results to HTML table, failing with error %v\n", err)
	}
}
