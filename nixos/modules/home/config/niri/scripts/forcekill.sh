
pid_output=$(niri msg pick-window | grep "PID:")

pid=$(echo "$pid_output" | awk '{print $2}')

if [[ -n "$pid" && "$pid" =~ ^[0-9]+$ ]]; then
    echo "Killing process with PID: $pid"
    kill "$pid"
    
    if [[ $? -eq 0 ]]; then
        echo "Process terminated successfully"
    else
        echo "Failed to kill process. You might need to use kill -9"
        kill -9 "$pid"
    fi
else
    echo "No valid PID found"
    exit 1
fi
