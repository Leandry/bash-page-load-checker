#!/usr/bin/env bash
display_help() {
    echo "$(basename "$0")"
    echo
    echo "Bash script checking website basic performance"
    echo
    echo "Usage: bash $(basename "$0")"
    echo
    echo "   -h, --help                         Display help information"
    echo "   -u, --url                          Website URL (example: http://example.com)"
    echo "   -i, --iterations                   Check iterations count"
    echo
    exit 0
}

close_on_error(){
        echo -e "\e[1;41;15m ERROR:  $@ \e[0m"
        exit 99
}

validate_url(){
    regex='(https?|http?)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'
    [[ -z ${URL} ]] && read -p "Enter website URL:  " URL
    if [[ ${URL} =~ ${regex} ]]; then
       if curl --output /dev/null --silent --head --fail "${URL}"; then
       echo "URL: ${URL} is valid ✔️"
       else
              display_help & close_on_error "URL: ${URL} not reachable."
       fi
    else
       display_help & close_on_error "URL: ${URL} not correct."
    fi
}
validate_iterations(){
    regex='^[0-9]+$'
    [[ -z ${ITERATIONS} ]] && ITERATIONS=1
    if [[ ${ITERATIONS} =~ ${regex} ]]; then
        [[ ${ITERATIONS} = 0 ]] && close_on_error "Iterations should be greater than 0"
    else
        close_on_error "Iterations should be a number greater than 0"
    fi
}

test_url(){
for ((i=1; i<=${ITERATIONS}; i++))
    do
        curl --silent -o /dev/null -w "Connect: %{time_connect} TTFB: %{time_starttransfer} Total time: %{time_total} \n" ${URL}
done
}

while [[ $# -ne 0 ]]
do
    arg="$1"
    case "$arg" in
        -h)
            display_help
            ;;
        -u | --url)
            URL=${2}
            ;;
        -i | --iterations)
            ITERATIONS=${2}
            ;;
        -*)
            close_on_error "Unknown parameter: ${arg}" & display_help
            ;;
    esac
    shift
done

validate_url
validate_iterations
test_url
