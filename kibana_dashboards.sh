#!/bin/bash

scripts_path=$(echo $0 | sed 's#/kibana_dashboards.sh$##')
results_base_dir=/var/results/dashboards/
dashboards_file=$results_base_dir/dashboards.json
nodejs_bin=/usr/bin/node
nodejs_script=$scripts_path/kibana_dashboards.js
kibana_url="http://localhost:9200/.kibana/_search?size=1000"

get_dashboards_ids_and_titles () {

curl -XGET "$kibana_url" -H 'Content-Type: application/json' -d'
{
  "_source": ["_id", "dashboard.title"],
  "query": {
    "bool": {
      "filter": [
        {"term": {"type": "dashboard"}}
      ]
    }
  }
}' > $dashboards_file

perl -p -i -e 's/"_index"/\n"_index"/g' $dashboards_file
perl -p -i -e 's/.*dashboard:(.+?)".*title":"(.+?)".*/\1,\2/' $dashboards_file
sed -i -e '/^{.*/d' $dashboards_file

# If there is filter, apply it only to the dashboard title
if [[ $# -eq 1 ]]; then
  grep -E "^.*,.*$1" $dashboards_file > $dashboards_file.tmp
  mv $dashboards_file.tmp $dashboards_file
fi

}

take_screenshots () {
  export CHROME_DEVEL_SANDBOX="/opt/chrome/latest/chrome_sandbox"
  total_dashboards=$(cat $dashboards_file | wc -l )
  i=1
  while read line; do
    dashboard_id=$(echo $line | cut -f1 -d,)
    dashboard_title=$(echo $line | cut -f2 -d,)
    subdir=$(echo $dashboard_title | perl -p -e 's# - #/#g')
    mkdir -p "$results_base_dir/$subdir" 2>/dev/null
    echo "---($i/$total_dashboards)---title=$dashboard_title, id=$dashboard_id--------"
    start_date=$(date -d "last Monday -$weeks weeks" +%F)
    $nodejs_bin $nodejs_script "$results_base_dir" "$dashboard_title" "$dashboard_id" $start_date
    i=$(($i + 1))
  done < $dashboards_file
  rm $dashboards_file
}

print_help () {
  echo "Usage: $0 [weeks] [filter]"
	echo -e "\n --Options----------------------------------------------------------------------------------------------------------------------"
	echo "	weeks: number of weeks to be reported from the current date (optional, but required if a filter is applied) Default: 52"
	echo "	filter: filter to be applied to the dashboard title (optional) Default: no filter "
}
  case $# in
    0 )
      weeks=52
      get_dashboards_ids_and_titles
      take_screenshots
    ;;

    1 )
      weeks=$1
      get_dashboards_ids_and_titles
      take_screenshots
    ;;

    2 )
      weeks=$1
      filter=$2
      get_dashboards_ids_and_titles "$filter"
      take_screenshots
    ;;

    * )
      print_help
      exit 1
    ;;
  esac
