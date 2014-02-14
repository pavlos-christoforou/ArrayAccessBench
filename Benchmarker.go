/*	Reads data from BenchmarkData.dat (five rows per language, first is name, second is compile command or "-" if interpreted, third is run command, fourth is source file name, fifth is executable name).
	Compiles the languages, recording compile time and the size of the executable generated.
	Runs them, recording their resident memory usage and the size.
	Waits WaitTime seconds between each run.
	Outputs their speed, memory usage and compile time to stdout.
	Compresses their source files and records their size.
	Outputs all the above data to an HTML table in ResultsTable.html
*/

package main

import (
	"bytes"
	"fmt"
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
	langFile  = "BenchmarkData.dat"
	WaitTime  = 1
)

var (
	langs     []Lang
	dataLines []string
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

func loadLangs() {
	contents, err := ioutil.ReadFile(langFile)
	if err != nil {
		panic(err)
	}
	dataLines = strings.Split(string(contents), "\n")
	for i, _ := range dataLines {
		dataLines[i] = strings.Trim(dataLines[i], "\n\r")
	}
	for i := 0; i < len(dataLines)-1; i += 5 {
		thisLang := Lang{Name: dataLines[i], Commands: dataLines[i+1], Run: dataLines[i+2], SourceName: dataLines[i+3], ExeName: dataLines[i+4], Loaded: true, Interpreted: dataLines[i+1] == "-"}
		langs = append(langs, thisLang)
	}
}

func compileLangs() {
	for i, lang := range langs {
		if lang.Interpreted == true {
			continue
		}
		fmt.Printf("Now compiling language %v.\n", lang.Name)
		initT := time.Now()
		_, err := runCommand(lang.Commands)
		if err != nil {
			fmt.Printf("Compilation of %v failed with error of %v\n", lang.Name, err)
			langs[i].Loaded = false
		}
		endT := time.Now()
		langs[i].CmplTime = endT.Sub(initT).Seconds()
	}
}

func runLangs() {
	for i, lang := range langs {
		if lang.Loaded == false {
			continue
		}
		fmt.Println("Pausing to allow the system to cool down.")
		time.Sleep(WaitTime * time.Second)
		fmt.Printf("Now running language %v.\n", lang.Name)
		out, err := runCommand(`command time -f 'max resident:\t%M KiB' ` + lang.Run)
		if err != nil {
			fmt.Printf("Running %v failed with error of %v\n", lang.Name, err)
			langs[i].Loaded = false
		}

		langs[i].Results = string(out)
		
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
}

func parseResults() {
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
}

func measureLangSizes() {
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
}

func calcLangStats() {
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
		langs[i].PcntBestTime = float64(minTime/ lang.BestRun)
		langs[i].Compiler = strings.Split(lang.Commands, " ")[0]
	}
}

type BySpeed []Lang
func (s BySpeed) Len() int           { return len(s) }
func (s BySpeed) Swap(i, j int)      { s[i], s[j] = s[j], s[i] }
func (s BySpeed) Less(i, j int) bool { return (1/ (s[i].BestRun) ) < (1/ (s[j].BestRun) ) }

func sortLangs(){
	sort.Sort(BySpeed(langs))
}

func putResultsInHtmlTable() {
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
			<td style="text-align: center;" width="81"><span style="color: #000000;"><em>Compile Time</em></span></td>
			<td style="text-align: center;" width="81"><span style="color: #000000;"><em>Running time</em></span></td>
			<td style="text-align: center;" width="81"><span style="color: #000000;"><em>% Fastest</em></span></td>
			<td style="text-align: center;" width="70"><span style="color: #000000;"><em>Resident mem use (KiB)</em></span></td>
			<td style="text-align: center;" width="70"><span style="color: #000000;"><em>Compressed source size</em></span></td>
			<td style="text-align: center;" width="70"><span style="color: #000000;"><em>Lines of code</em></span></td>
			<td style="text-align: center;" width="70"><span style="color: #000000;"><em>Number of characters</em></span></td>
			<td style="text-align: center;" width="70"><span style="color: #000000;"><em>Executable size (KB)</em></span></td>
			</tr>
	`
	sortLangs()
	for _, lang := range langs {
		if lang.Loaded == false {
			continue
		}
		var execResults bytes.Buffer
		err = tmpl.Execute(&execResults, lang)
		table += execResults.String()
	}

	table = table + `
		</tbody>
		</table>`

	err = ioutil.WriteFile("ResultsTable.html", []byte(table), 0644)
	if err != nil {
		fmt.Printf("Failed to write results to HTML table, failing with error %v\n", err)
	}
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
	loadLangs()
	compileLangs()
	runLangs()
	parseResults()
	measureLangSizes()
	calcLangStats()
	putResultsInHtmlTable()
}
