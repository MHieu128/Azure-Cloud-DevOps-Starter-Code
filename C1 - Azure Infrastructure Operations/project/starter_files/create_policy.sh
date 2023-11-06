az policy definition create --name tagging-policy \
                            --display-name "Enforce tagging policy" \
                            --description "This policy ensures all indexed in this resources have tags and deny deployment if none." \
                            --rules tagging-policy.json \
                            --params policy-param.json \
                            --mode Indexed
az policy assignment create --name tagging-assignment \
                            --display-name "Enforce tagging assignment" \
                            --policy tagging-policy \
                            --params "{ \"tagName\": {\"value\": \"Name\"} }"