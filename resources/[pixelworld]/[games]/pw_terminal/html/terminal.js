$(function () {
    window.addEventListener('message', function (event) {
        if (event.data.type == "enableui") {
            document.body.style.display = event.data.enable ? "block" : "none";
            if (event.data.enable) $("#terminalInput").focus();
        }
    });
});

var hacking = false;
var hackerName = ['Tr1N1ty', 'N3O', 'M0rph3us', 't4Nk', 'b1sh0p', '0r4c13', 'sw1tX', 'cYPh3r', 'ap0c', 'd0z3R'];
var virusName = ["1337", "t0xic", "ph4ntom", "4LPhA", "v1rus", "biTe", "krypt0", "cyb3r", "Bi0", "ac1d", "gh0st", "L0rd", "r4dical", "PWNER", "H4X0R", "buRn", "MuX", "d3st0y3r", "phr34k", "Pl4gu3", "0verrid3", "Ch40s"];
var activeVirus = virusName[Math.floor((Math.random() * virusName.length))];
var ranIntervals = 0
var PIDs = new Array();
PIDs[0] = randomPID(1000, 4000);
PIDs[1] = randomPID(PIDs[0], 6000);
PIDs[2] = randomPID(PIDs[1], 8000);
PIDs[3] = randomPID(PIDs[2], 9999);

setInterval(function () {
    if (!hacking) {
        var prevVirus = activeVirus;
        activeVirus = virusName[Math.floor((Math.random() * virusName.length))];
        delete Object.assign(directories[".root"].content, { [activeVirus + ".sh"]: directories[".root"].content[prevVirus + ".sh"] })[prevVirus + ".sh"];
        ranIntervals++;
        var oldPid = PIDs[3];
        PIDs[3] = randomPID(oldPid, oldPid + (1000 * ranIntervals));
    }
}, 120 * 1000);

var commandList = {
    bash: "executes commands read from a file",
    cat: "cat [filename] will print the contents of that file.",
    cd: "cd [directory] will switch current directory to [directory].",
    clear: "clears all text in the terminal.",
    hack: "",
    help: "lists possible terminal commands.",
    history: "lists the command line history.",
    logout: "exits a login shell.",
    ls: "lists information about files and directories.",
    man: "describes a command.",
    ps: "lists the current processes.",
    uname: "prints information about the machine and operating system it is run on."
};

var directories = {
    home: {
        type: "folder",
        visible: true,
        content: {
            "file1.txt": {
                type: "text",
                content: "desc",
                visible: true
            }
        }
    },
    opt: {
        type: "folder",
        visible: true,
        content: {

        }
    },
    bin: {
        type: "folder",
        visible: true,
        content: {

        }
    },
    ".root": {
        type: "folder",
        visible: false,
        content: {
            [activeVirus + ".sh"]: {
                type: "exe",
                visible: false,
                content: "virus"
            }
        }
    }
};

var defaultUser = "root@pixelworld.com: ~";
var user = defaultUser;
var curDirectory = "home";
var commandHistory = [];
var commandIndex = -1;

function randomPID(min, max) {
    return Math.floor(Math.random() * (max - min) + min);
}

function closeTerminal() {
    document.body.style.display = 'none';
    $.post('http://pw_terminal/escape', JSON.stringify({}));
    location.reload();
}

$(document).on('click', '[data-act=closeWindow]', function () {
    closeTerminal()
});

$(document).ready(function () {
    $("#terminal").on("click", function () {
        $("#terminalInput").focus();
    });

    function calculateOffset() {
        var sendSpaces = "";
        var curLength = PIDs[3].toString().length;
        if (curLength > 4) {
            for (i = 1; i <= curLength - 4; i++) {
                sendSpaces = sendSpaces + "&nbsp;"
            }
        }
        return sendSpaces;
    }

    function sendCommand(input) {
        var execCommand = input.split("./");
        if (execCommand[1] && execCommand[1].length > 1) {
            runFile(execCommand[1]);
        } else {
            var command = input.split(" ")[0];
            var secondary = input.split(" ")[1];
            if (
                (commandList[command] === undefined &&
                    command != "continue") &&
                command
            ) {
                replaceInput();
                $("#terminalOutput").append(
                    'Invalid command "' + command + '"<br>type "help" for more options<br>'
                );
                addInput();
            }
            if (
                input === "ls -la" ||
                input === "ls -a" ||
                input === "ls -all" ||
                input === "ls -l"
            ) {
                printFiles(true);
                return;
            }
            switch (command) {
                case "hack":
                    hack();
                    break;
                case "bash":
                    if (secondary) runFile(secondary);
                    break;
                case "uname":
                    replaceInput();
                    $("#terminalOutput").append(
                        "PixelOS pixelworld.com x86_64 5.0 GNU/Linux<br>" + new Date().toString() + "<br>"
                    );
                    addInput();
                    break;
                case "history":
                    history(secondary);
                    break;
                case "logout":
                    closeTerminal();
                    break;
                case "ls":
                    printFiles(false);
                    break;
                case "cat":
                    if (!secondary) break;
                    printFile(secondary);
                    break;
                case "help":
                    printList(commandList);
                    break;
                case "clear":
                    clear();
                    break;
                case "man":
                    if (secondary) man(secondary);
                    break;
                case "ps":
                    var calculateSpacing = calculateOffset()
                    replaceInput();
                    $("#terminalOutput").append(
                        calculateSpacing + "&nbsp;PID TTY&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;TIME&nbsp;CMD<br>" +
                        calculateSpacing + PIDs[0] + " pts/1&nbsp;&nbsp;    00:00:00 bash<br>" +
                        calculateSpacing + PIDs[1] + " pts/1&nbsp;&nbsp;    00:00:00 ps<br>" +
                        calculateSpacing + PIDs[2] + " pts/1&nbsp;&nbsp;    00:00:00 chrome<br>" +
                        PIDs[3] + " pts/1&nbsp;&nbsp;    00:00:00 ./" + activeVirus + ".sh<br>"
                    );
                    addInput();
                    break;
                case "cd":
                    if (secondary) cd(secondary);
                    break;

            }
        }
    }

    var c = 0
    var txt = [
        'FORCE: XX0022. ENCYPT://000.222.2345',
        'TRYPASS: ********* AUTH CODE: ALPHA GAMMA: 1___ PRIORITY 1',
        'RETRY: REINDEER FLOTILLA',
        'X:> /PIXELWORLD/GAMES/FIVEM/ EXECUTE -PLAYERS 128',
        '================================================',
        'Priority 1 // local / scanning...',
        'scanning ports...',
        'BACKDOOR FOUND (23.45.23.12:30120)',
        'BACKDOOR FOUND (13.66.23.12:30130)',
        'BACKDOOR FOUND (13.66.23.12:30140)',
        '...',
        '...',
        'BRUTE.EXE -r -z',
        '...locating vulnerabilities...',
        '...vulnerabilities found...',
        'MCP/> DEPLOY CLU',
        'SCAN: __ 0100.0000.0554.0080',
        'SCAN: __ 0020.0000.0553.0080',
        'SCAN: __ 0001.0000.0554.0550',
        'SCAN: __ 0012.0000.0553.0030',
        'SCAN: __ 0100.0000.0554.0080',
        'SCAN: __ 0020.0000.0553.0080',
        'FFF BJDY **** ++home hack',
        'BACKDOOR FOUND (23.45.23.12:30120)',
        'BACKDOOR FOUND (13.66.23.12:30130)',
        'BACKDOOR FOUND (13.66.23.12:30140)',
        '=============================================',
        '...',
        '...',
        'BRUTE.EXE -r -z',
        '...locating vulnerabilities...',
        '...vulnerabilities found...',
        'ACCESS GRANTED.'
    ]

    var curIndex = 0
    var curIteration = 0

    function typeName() {
        setTimeout(function() {
            if (curIteration > (txt[curIndex].length - 1)) {
                if((curIndex + 1) > (txt.length - 1)) {
                    curIndex = 0;
                    curIteration = 0;
                    replaceInput();
                    addInput();
                    hacking = false;
                } else {
                    curIndex++;
                    curIteration = 0;
                    $('#terminalOutput').append("<br>");
                    $('#terminalOutput').append(txt[curIndex][curIteration]);
                    curIteration++;
                    document.getElementById('terminalOutput').scrollTop = 9999999;
                    typeName();
                }
            } else {
                $('#terminalOutput').append(txt[curIndex][curIteration]);
                curIteration++;
                typeName();
            }
        }, 20);
    }

    function hack() {
        if (!hacking) {
            hacking = true;
            var bg = document.getElementById("terminal");
            var input = document.getElementById("terminalInput");
            var output = document.getElementById("terminalOutput");
            var closeButton = document.getElementById("closeButton");
            bg.style.background = "#000000";
            input.style.color = "#20C20E";
            output.style.color = "#20C20E";
            closeButton.style.background = "#4F781E";
            user = hackerName[Math.floor((Math.random() * hackerName.length))] + "@p1x3Lw0RLd.c0M: ~";
            clear();
            replaceInput();
            typeName();
        }
    }

    function runFile(file) {
        if ((curDirectory && directories[curDirectory].content[file] && directories[curDirectory].content[file].type === "exe") ||
            (curDirectory === "" && directories[file] && directories[file].type === "exe")) {
            //run file
        } else if ((curDirectory && directories[curDirectory].content[file] === undefined) || (curDirectory === "" && directories[file] === undefined)) {
            replaceInput();
            $("#terminalOutput").append(
                '"' + file + '"' + ' file not found.<br>'
            );
            addInput();
        } else if ((curDirectory && directories[curDirectory].content[file] && directories[curDirectory].content[file].type !== "exe") ||
            (curDirectory === "" && directories[file] && directories[file].type !== "exe")) {
            var fType = (curDirectory ? directories[curDirectory].content[file].type : directories[file].type)
            switch (fType) {
                case "text":
                    fType = " text file";
                    break;
                case "folder":
                    fType = " directory";
                    break;
                default:
                    fType = "n invalid file"
            }

            replaceInput();
            $("#terminalOutput").append(
                '"' + file + '"' + ' is a' + fType + '.<br>'
            );
            addInput();
        }
    }

    function history(arg) {
        replaceInput();
        if (arg === "-c") {
            commandHistory = [];
        } else {
            if (commandHistory.length > 0) {
                for (i = (commandHistory.length - 1); i >= 0; i--) {
                    $("#terminalOutput").append(
                        (i + 1) + " " + commandHistory[i] + "<br>"
                    );
                }
            }
        }
        addInput();
    }

    function switchDirectory(target) {
        curDirectory = target;
        replaceInput();
        addInput();
    }

    function cd(input) {
        if (input === "~" || input === "..") {
            switchDirectory("");
            return;
        }

        var found = false;

        Object.keys(directories).forEach(function (key) {
            if (key === input) {
                found = true;
                switchDirectory(key)
            }
            if (found) return;
        });

        if (found === false) {
            replaceInput();
            $("#terminalOutput").append(
                '"' + input + '"' + ' Directory not found.<br>'
            );
            addInput();
        }
    }

    function man(input) {
        if (commandList[input] !== undefined) {
            replaceInput();
            $("#terminalOutput").append(
                '"' + input + '"' + "  " + commandList[input] + "<br>"
            );
            addInput();
        } else {
            replaceInput();
            $("#terminalOutput").append(
                '"' +
                input +
                '"' +
                '  is not a valid command, try typing "help" for options.<br>'
            );
            addInput();
        }
    }

    function clear() {
        replaceInput();
        $("#terminalOutput").empty();
        addInput();
    }

    function printFile(file) {
        if ((curDirectory && directories[curDirectory].content[file] && directories[curDirectory].content[file].type === 'text') || (curDirectory === "" && directories[file] && directories[file].type === 'text')) {
            replaceInput();
            $("#terminalOutput").append((curDirectory ? directories[curDirectory].content[file].content : directories[file].content) + "<br>");
            addInput();
        } else if ((curDirectory === "" && directories[file]) || (curDirectory && directories[curDirectory].content[file] && directories[curDirectory].content[file].type === 'folder')) {
            replaceInput();
            $("#terminalOutput").append(
                '"' + file + '"' + ' is a directory. Try typing "cd ' + file + '".<br>'
            );
            addInput();
        } else if ((curDirectory && directories[curDirectory].content[file] === undefined) || (curDirectory === "" && directories[file] === undefined)) {
            replaceInput();
            $("#terminalOutput").append(
                '"' + file + '"' + ' is an invalid file name.  Try typing "ls".<br>'
            );
            addInput();
        }
    }

    function printList(list) {
        replaceInput();
        Object.keys(commandList).forEach(function (key) {
            $("#terminalOutput").append(key + "<br>");
        });
        addInput();
    }

    function printFiles(all) {
        replaceInput();
        if (curDirectory) {
            Object.keys(directories[curDirectory].content).forEach(function (key) {
                if (all === true || (all === false && directories[curDirectory].content[key].visible)) {
                    var color = ""
                    switch (directories[curDirectory].content[key].type) {
                        case "folder":
                            color = "#6079A2";
                            break;
                        case "file":
                            color = "#83D733";
                            break;
                        default:
                            color = "#FFFFFF"
                    }
                    $("#terminalOutput").append(
                        "<span style='color:" + color + "'>" + key + "</span>" + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
                    );
                }
            });
        } else {
            Object.keys(directories).forEach(function (key) {
                if (all === true || (all === false && directories[key].visible)) {
                    var color = ""
                    switch (directories[key].type) {
                        case "folder":
                            color = "#6079A2";
                            break;
                        case "file":
                            color = "#83D733";
                            break;
                        default:
                            color = "#FFFFFF"
                    }
                    $("#terminalOutput").append(
                        "<span style='color:" + color + "'>" + key + "</span>" + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
                    );
                }
            });
        }
        $("#terminalOutput").append("<br>");
        addInput();
    }

    function replaceInput() {
        var value = $("#terminalInput").val();
        $("#terminalInput").remove();
        $("#terminalOutput").append((value || "") + "<br>");
    }

    function addInput() {
        var userDir = user + (curDirectory ? "/" + curDirectory : "") + ' $';
        $("#terminalOutput").append(
            userDir + ' <input id="terminalInput" spellcheck="false"></input>'
        );

        setTimeout(function () {
            $("#terminalInput").focus();
        }, 10);

        $("#terminalInput").keydown(function (e) {
            var command = $("#terminalInput").val();
            if (e.keyCode == 13) {
                sendCommand(command);
                if (command !== "history" && command !== "history -c") {
                    commandHistory.unshift(command);
                }
                commandIndex = -1;
            } else if (e.keyCode == 9) {
                e.preventDefault();
                autoCompleteInput(command);
            } else if (e.keyCode == 38 && commandIndex != commandHistory.length - 1) {
                e.preventDefault();
                commandIndex++;
                $("#terminalInput").val(commandHistory[commandIndex]);
            } else if (e.keyCode == 40 && commandIndex > -1) {
                e.preventDefault();
                $("#terminalInput").val(commandHistory[commandIndex]);
                commandIndex--;
            } else if (e.keyCode == 67 && e.ctrlKey) {
                $("#terminalInput").val(command + "^C");
                replaceInput();
                addInput();
            } else if (e.keyCode == 27) { // Escape key
                closeTerminal();
            }
        });
    }

    function autoCompleteInput(command) {
        var command = $("#terminalInput").val();
        var fileList = null;
        var validList = [];
        var input = [];
        if (command.substring(0, 2) === "./") {
            fileList = (curDirectory ? directories[curDirectory].content : directories);
            input[0] = "./";
            input[1] = command.substring(2);
        } else {
            input = $("#terminalInput").val().split(" ");
            fileList = input[0] === "man" ? commandList : (curDirectory ? directories[curDirectory].content : directories);
        }
        if (input.length === 2 && input[1] != "") {
            Object.keys(fileList).forEach(function (file) {
                if (file.substring(0, input[1].length) === input[1]) {
                    validList.push(file);
                }
            });
            if (validList.length > 1) {
                replaceInput();
                validList.forEach(function (option) {
                    $("#terminalOutput").append(option + "   ");
                });
                $("#terminalOutput").append("<br>");
                addInput();
                $("#terminalInput").val(command);
            } else if (validList.length === 1) {
                $("#terminalInput").val(
                    command + validList[0].substring(input[1].length, validList[0].length)
                );
            }
        } else if (command.length) {
            Object.keys(commandList).forEach(function (option) {
                if (option.substring(0, input[0].length) === input[0]) {
                    validList.push(option);
                }
            });
            Object.keys((curDirectory ? directories[curDirectory].content : directories)).forEach(function (option) {
                if (option.substring(0, input[0].length) === input[0]) {
                    validList.push(option);
                }
            });
            if (validList.length > 1) {
                replaceInput();
                validList.forEach(function (option) {
                    $("#terminalOutput").append(option + "   ");
                });
                $("#terminalOutput").append("<br>");
                addInput();
                $("#terminalInput").val(command);
            } else if (validList.length === 1) {
                $("#terminalInput").val(
                    command + validList[0].substring(input[0].length, validList[0].length)
                );
            }
        }
    }

    addInput();
});

