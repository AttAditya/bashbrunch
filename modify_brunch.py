with open('brunch.sh', 'r') as f:
    lines = f.readlines()

# 1. Remove the echo "Exiting..." inside the /q block
new_lines = []
for line in lines:
    # We only want to remove the one that is part of the /q case
    # but since there's only one "Exiting..." in the file, this is safe.
    if 'echo "Exiting..."' in line:
        continue
    new_lines.append(line)

# 2. Find the 'done' that ends the main loop
# It is the last 'done' before 'history -w'
insert_pos = -1
for i in range(len(new_lines) - 1, -1, -1):
    if new_lines[i].strip() == 'done':
        # Verify this is the main loop by checking for history -w shortly a[1D[K
after
        for j in range(i + 1, len(new_lines)):
            if 'history -w' in new_lines[j]:
                insert_pos = i + 1
                break
        if insert_pos != -1:
            break

if insert_pos != -1:
    exit_block = [
        '
if [ "$requested_exit" -eq 1 ]; then
',
        '  echo "Exitting! (session terminated by ai)"
',
        'else
',
        '  echo "Exitting!"
',
        'fi
'
    ]
    # Insert the block at the identified position
    for idx, line in enumerate(exit_block):
        new_lines.insert(insert_pos + idx, line)

with open('brunch.sh', 'w') as f:
    f.writelines(new_lines)
