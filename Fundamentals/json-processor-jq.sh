:<<"COMMENTS"

jq
   is a lightweight and flexible command-line JSON processor.
Think of it as sed, awk, or grep, but built specifically for JSON data.
It allows you to slice, filter, map, and transform structured JSON data effortlessly directly from your terminal.

echo '{"name": "Alice", "age": 30}' | jq '<filter>'

Essential jq Filters:
----------------------

1) Pretty Print (.) - The dot filter takes valid JSON and formats it with proper indentation and syntax highlighting.
   Example:
   echo '{"name": "Alice", "age": 30}' | jq '.'

2) Extract a Field (.key): Use dot notation to grab the value of a specific key.
   Example:
   echo '{"name": "Alice", "age": 30}' | jq '.name'
   # Output: "admin"

3) Access Nested Objects (.key1.key2): Drill down into multi-level JSON structures seamlessly.
   Example:
   echo '{"user": {"name": "Alice", "age": 30}}' | jq '.user.name'
   # Output: "Alice"

   Example:
   echo '{"user": {"profile": {"city": "London"}}}' | jq '.user.profile.city'
   # Output: "London"

4) Work with Arrays (.[index]): Access specific elements by their index, or unpack an entire array using [].
   Example:
   echo '{"users": ["Alice", "Bob", "Charlie"]}' | jq '.users[1]'
   # Output: "Bob"

   Example:
   echo '["apple", "banana", "cherry"]' | jq '.[1]'
   # Output: "banana"

5) Filter Data (select()): Filter items in an array based on specific conditions.
   Example:
   echo '[{"name": "Alice", "age": 30}, {"name": "Bob", "age": 25}]' | jq '.[] | select(.age > 28)'
   # Output: {"name": "Alice", "age": 30}

Examples
-----------

patronictl -c /etc/patroni/patroni.yml list
    root@docpg-cls1-pg1:/# patronictl -c /etc/patroni/patroni.yml list
    + Cluster: docpg-cls1 (7683910313230012283) --+-----------+----+-----------+------------------+
    | Member         | Host        | Role         | State     | TL | Lag in MB | Tags             |
    +----------------+-------------+--------------+-----------+----+-----------+------------------+
    | docpg-cls1-pg1 | 172.18.0.11 | Leader       | running   |  1 |           |                  |
    +----------------+-------------+--------------+-----------+----+-----------+------------------+
    | docpg-cls1-pg2 | 172.18.0.12 | Sync Standby | streaming |  1 |         0 |                  |
    +----------------+-------------+--------------+-----------+----+-----------+------------------+
    | docpg-cls1-pg3 | 172.18.0.13 | Replica      | streaming |  1 |         0 | nofailover: true |
    |                |             |              |           |    |           | nosync: true     |
    +----------------+-------------+--------------+-----------+----+-----------+------------------+

patronictl -c /etc/patroni/patroni.yml list -f json
    root@docpg-cls1-pg1:/# patronictl -c /etc/patroni/patroni.yml list -f json
    [{"Cluster": "docpg-cls1", "Member": "docpg-cls1-pg1", "Host": "172.18.0.11", "Role": "Leader", "State": "running", "TL": 1}, {"Cluster": "docpg-cls1", "Member": "docpg-cls1-pg2", "Host": "172.18.0.12", "Role": "Sync Standby", "State": "streaming", "TL": 1, "Lag in MB": 0}, {"Cluster": "docpg-cls1", "Member": "docpg-cls1-pg3", "Host": "172.18.0.13", "Role": "Replica", "State": "streaming", "TL": 1, "Lag in MB": 0, "Tags": {"nofailover": true, "nosync": true}}]

patronictl -c /etc/patroni/patroni.yml list -f json > /tmp/patronictl_output.json

    root@docpg-cls1-pg1:/# cat /tmp/patronictl_output.json 
    [{"Cluster": "docpg-cls1", "Member": "docpg-cls1-pg1", "Host": "172.18.0.11", "Role": "Leader", "State": "running", "TL": 1}, {"Cluster": "docpg-cls1", "Member": "docpg-cls1-pg2", "Host": "172.18.0.12", "Role": "Sync Standby", "State": "streaming", "TL": 1, "Lag in MB": 0}, {"Cluster": "docpg-cls1", "Member": "docpg-cls1-pg3", "Host": "172.18.0.13", "Role": "Replica", "State": "streaming", "TL": 1, "Lag in MB": 0, "Tags": {"nofailover": true, "nosync": true}}]

# Show in pretty format
cat /tmp/patronictl_output.json | jq '.'

# Extract all replica members in json quotes
cat /tmp/patronictl_output.json | jq '.[].Member'
    # Output:
    "docpg-cls1-pg1"
    "docpg-cls1-pg2"
    "docpg-cls1-pg3"

# Extract all replica members without json quotes
cat /tmp/patronictl_output.json | jq -r '.[].Member'
    # Output:
    docpg-cls1-pg1
    docpg-cls1-pg2
    docpg-cls1-pg3

# Extract current leader
cat /tmp/patronictl_output.json | jq -r '.[] | select(.Role == "Leader")'
    # Output:
    {
      "Cluster": "docpg-cls1",
      "Member": "docpg-cls1-pg1",
      "Host": "172.18.0.11",
      "Role": "Leader",
      "State": "running",
      "TL": 1
    }

# Extract current leader's member name
cat /tmp/patronictl_output.json | jq -r '.[] | select(.Role == "Leader") | .Member'
    # Output:
    docpg-cls1-pg1

  # How It Works
  -r (raw output): Prints the string without surrounding JSON quotes (so you get docpg-cls1-pg1 instead of "docpg-cls1-pg1").
  .[]: Unpacks the outer JSON array so we can process each member object individually.
  select(.Role == "Leader"): Filters the objects, keeping only the one where the Role key matches "Leader".
  .Member: Extracts the value of the Member field from that filtered object.

# Extract timeline of Leader
cat /tmp/patronictl_output.json | jq -r '.[] | select(.Role == "Leader") | .TL | tonumber'



COMMENTS


