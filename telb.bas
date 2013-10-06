'Written by James Albert

nomainwin
WindowWidth = 600
WindowHeight = 480
UpperLeftX=int((DisplayWidth-WindowWidth)/2)
UpperLeftY=int((DisplayHeight-WindowHeight)/2)

'global variable/array setup
dim lines$(1000), cnfdict$(100, 2)
global index, linecount, curvar
index = 1
curvar = 1
linecount = 0

'init rendering
print render()

'get value from given key
function getval$(key$)
    found = 0
    [restartgetval]
    if found = 0 then
        for i=1 to 100
            if cnfdict$(i, 1) = key$ then
                getval$ = cnfdict$(i, 2)
                found = 1
                goto [restartgetval]
            end if
         next
    end if
end function

'load .cnf file
function loadcnf()
    filedialog "choose config", "./.cnf", cnf$
    line$ = ""
    open cnf$ for input as #config
        varpoint = 0
        if eof(#config) <> 0 then [quit]
        while not(eof(#config))
            [read]
            varpoint = varpoint + 1
            line$ = inputto$(#config, chr$(10))
            decpoint = instr(line$, "=")
            if decpoint > 0 then
                key$ = left$(line$, decpoint-2)
                value$ = right$(line$, len(line$)-decpoint-1)
                cnfdict$(varpoint, 1) = key$
                cnfdict$(varpoint, 2) = value$
            else
                goto [quit]
            end if
        wend
        close #config
end function

'substitute {{var}} with key->value
function subvar$(lines$, l,r, var$, value$)
    pos = instr(lines$(i), var$)
    length = len(lines$)
    leftside$ = left$(lines$, l)
    rightside$ = right$(lines$, length-(len(leftside$)+len(var$)))
    lines$ = leftside$+value$+rightside$
    subvar$ = lines$
end function

'find each var in file
function findvars()
    print loadcnf()
    finding = 1
    [startfindvars]
    if len(lines$(1)) > 0 and finding = 1 then
        for i=1 to linecount
            [startfor]
            if i > linecount then
                finding = 0
                goto [startfindvars]
            end if
            startingpoint = instr(lines$(i), "{{", index)-1
            if startingpoint+1 > 0 then
                index = startingpoint
                endingpoint  = instr(lines$(i), "}}", index)+1
                varseg$ = left$(lines$(i), endingpoint)
                var$ = right$(varseg$, len(varseg$)-index)
                index = endingpoint
                value$ = getval$(var$)
                oldline$ = lines$(i)
                lines$(i) = subvar$(lines$(i), startingpoint, endingpoint, var$, value$)
                diff = abs(len(oldline$)-len(lines$(i)))
                if instr(lines$(i), "{{", index-diff) > 0 then
                    goto [startfor]
                end if
                index = 1
            else
                index = 1
                i = i + 1
                goto [startfor]
            end if
        next
     end if
end function

'write to output .bas file
function writefile()
    filedialog "choose destination", "./.bas", dest$
    open dest$ for output as #destination
        for i=1 to linecount
            print #destination, lines$(i)
        next
        close #destination
end function

'main function
function render()
    filedialog "choose template", "./.tmpl", tmpl$
    open tmpl$ for input as #template
        while not(eof(#template))
            linecount = linecount + 1
            lines$(linecount) = inputto$(#template, chr$(10))
        wend
        print findvars()
        close #template
    print writefile()
end function

[quit]
    close #template
