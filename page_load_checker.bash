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
        PAGE_LOAD_INFO=$(curl --silent -o /dev/null -w "%{time_connect} %{time_starttransfer} %{time_total} \n" ${URL})

        connect_arr[$i-1]=$(echo ${PAGE_LOAD_INFO} | awk '{print $1}')
        ttfb_arr[$i-1]=$(echo ${PAGE_LOAD_INFO} | awk '{print $2}')
        total_arr[$i-1]=$(echo ${PAGE_LOAD_INFO} | awk '{print $3}')

        echo "Connect: ${connect_arr[$i-1]} TTFB: ${ttfb_arr[$i-1]} Total Time: ${total_arr[$i-1]}"
done
echo "▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔"
connect_arr_count=0; ttfb_arr_total=0; total_arr_total=0;
connect_total=0; ttfb_arr_count=0; total_arr_count=0;
for i in ${connect_arr[@]}
   do
     connect_total=$(echo $connect_total+$i | bc )
     ((connect_arr_count++))
   done
for i in ${ttfb_arr[@]}
   do
     ttfb_arr_total=$(echo $ttfb_arr_total+$i | bc )
     ((ttfb_arr_count++))
   done
for i in ${total_arr[@]}
   do
     total_arr_total=$(echo $total_arr_total+$i | bc )
     ((total_arr_count++))
   done
avarage_connect=$(echo "scale=6; $connect_total / $connect_arr_count" | bc)
avarage_ttfb=$(echo "scale=6; $ttfb_arr_total / $ttfb_arr_count" | bc)
avarage_total=$(echo "scale=6; $total_arr_total / $total_arr_count" | bc)
echo "Average Connect Time: ${avarage_connect}"
echo "Average TTFB Time: ${avarage_ttfb}"
echo "Average Total Time: ${avarage_total}"

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
