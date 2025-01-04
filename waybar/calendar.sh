events=$(olmonokod events)
events_human=$(echo $events | jq -r '.[] | [.starts_at_human, .summary] | join(" ")' | sed -z 's/\n/\\n\\n/g')
event_count=$(echo $events | jq -r length)

printf "{ \"text\": \"%s \", \"tooltip\": \"%s\" }\n" \
       "$event_count" "$events_human"
