events_human=$(olmonokod events | jq -r '.[] | [.starts_at_human, .summary] | join(" ")' | sed -z 's/\n/\\n\\n/g')

printf "{ \"text\": \"%s\", \"tooltip\": \"%s\" }\n" \
       "_" "$events_human"
