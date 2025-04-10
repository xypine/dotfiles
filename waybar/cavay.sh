# Adapted from https://github.com/PROxZIMA/caway

# Nuke all internal spawns when script dies
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM

BARS=16;
FRAMERATE=90;
EQUILIZER=1;

# Get script options
while getopts 'b:f:m:eh' flag; do
    case "${flag}" in
        b) BARS="${OPTARG}" ;;
        f) FRAMERATE="${OPTARG}" ;;
        e) EQUILIZER=0 ;;
        h)
            echo "caway usage: caway [ options ... ]"
            echo "where options include:"
            echo
            echo "  -b <integer>  (Number of bars to display. Default 8)"
            echo "  -f <integer>  (Framerate of the equilizer. Default 60)"
            echo "  -e            (Disable equilizer. Default enabled)"
            echo "  -h            (Show help message)"
            exit 0
            ;;
    esac
done

bar=" ▁▂▃▄▅▆▇█"
barl=$((${#bar} - 1))
dict="s/;//g;"

# creating "dictionary" to replace char with bar + thin space " "
i=0
while [ $i -lt ${#bar} ]
do
    dict="${dict}s/$i/${bar:$i:1}/g;"
    i=$((i=i+1))
done

# Remove last extra thin space
dict="${dict}s/.$//;"

clean_create_pipe() {
    if [ -p $1 ]; then
        unlink $1
    fi
    mkfifo $1
}

kill_pid_file() {
    if [[ -f $1 ]]; then
        while read pid; do
            { kill "$pid" && wait "$pid"; } 2>/dev/null
        done < $1
    fi
}

# PID of the cava process and while loop launched from the script
cava_waybar_pid="/tmp/cava_waybar_pid"

# Clean pipe for cava
cava_waybar_pipe="/tmp/cava_waybar.fifo"
clean_create_pipe $cava_waybar_pipe

# Custom cava config
cava_waybar_config="/tmp/cava_waybar_config"
echo "
[general]
mode = normal
framerate = $FRAMERATE
bars = $BARS
autosens = 0
sensitivity = 200

[output]
method = raw
raw_target = $cava_waybar_pipe
data_format = ascii
ascii_max_range = $barl
channels = mono

[smoothing]
noise_reduction = 15

[eq]
1 = 15 # bass
2 = 12
3 = 11 # midtone
4 = 8
5 = 7 # treble
" > $cava_waybar_config

# Clean pipe for playerctl
playerctl_waybar_pipe="/tmp/playerctl_waybar.fifo"
clean_create_pipe $playerctl_waybar_pipe

# playerctl output into playerctl_waybar_pipe
playerctl -a metadata --format '{"text": "{{title}}", "tooltip": "{{playerName}} : {{title}} - {{artist}}", "alt": "{{status}}", "class": "{{status}}"}' -F >$playerctl_waybar_pipe &

# Read the playerctl o/p via its fifo pipe
while read -r line; do
    # Kill the cava process to stop the input to cava_waybar_pipe
    kill_pid_file $cava_waybar_pid

    players=$(playerctl -l 2>/dev/null)

    tooltip=""
    main_text=""
    main_class=""
    main_status=""
    selected_player=""

    for player in $players; do
        metadata=$(playerctl --player="$player" metadata --format '{{status}}|{{playerName}}|{{title}} - {{artist}}' 2>/dev/null)

        [[ -z $metadata ]] && continue

        status=$(cut -d'|' -f1 <<< "$metadata")
        name=$(cut -d'|' -f2 <<< "$metadata")
        title=$(cut -d'|' -f3 <<< "$metadata")

        # Build tooltip
        [[ -n $title ]] && tooltip+="${name}: ${title}\n"

        # Choose this player as the main one if it's playing and none has been selected yet
        if [[ -z $main_text && $status == "Playing" ]]; then
            main_text="$title"
            main_class="$status"
            main_status="$status"
            selected_player="$player"
        fi
    done

    # Fallback: use first non-empty title
    if [[ -z $main_text ]]; then
        for player in $players; do
            metadata=$(playerctl --player="$player" metadata --format '{{status}}|{{title}} - {{artist}}' 2>/dev/null)
            status=$(cut -d'|' -f1 <<< "$metadata")
            title=$(cut -d'|' -f2 <<< "$metadata")
            if [[ -n $title ]]; then
                main_text="$title"
                main_class="$status"
                main_status="$status"
                selected_player="$player"
                break
            fi
        done
    fi

    # Escape tooltip and trim newline
    tooltip=$(echo -e "$tooltip" | sed '/^$/d' | jq -Rs '.')

    # Output the final JSON
    echo "{\"text\": \"$main_text\", \"tooltip\": $tooltip, \"alt\": \"$main_status\", \"class\": \"$main_class\"}"

    # If the class says "Playing" and equilizer is enabled
    # then show the cava equilizer
    if [[ $EQUILIZER == 1 && $main_status == "Playing" ]]; then
        # Don't restart Cava if it's already running
        if [[ ! -f $cava_waybar_pid ]] || ! kill -0 "$(head -n1 $cava_waybar_pid 2>/dev/null)" 2>/dev/null; then
            # Show the playing title for 1 second
            sleep 0.3

            # cava output into cava_waybar_pipe
            cava -p $cava_waybar_config >$cava_waybar_pipe &

            # Save the PID of child process
            echo $! > $cava_waybar_pid

            # Read the cava o/p via its fifo pipe
            while read -r cmd2; do
                # Change the "text" key to bars
                # echo "$line" | jq --arg a $(echo $cmd2 | sed "$dict") '.text = $a + " ▎" + .text' --unbuffered --compact-output
                echo "$line" | jq --arg a $(echo $cmd2 | sed "$dict") '.text = $a' --unbuffered --compact-output
            done < $cava_waybar_pipe & # Do this fifo read in background

            # Save the while loop PID into the file as well
            echo $! >> $cava_waybar_pid
        fi
    else
        # If not playing or EQ disabled, kill cava process
        kill_pid_file "$cava_waybar_pid"
    fi
done < $playerctl_waybar_pipe
