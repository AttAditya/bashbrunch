version_file="$brunch_root/version.txt"

data_dir="$brunch_root/data"
config_dir="$brunch_root/config"
sessions_dir="$data_dir/sessions"

history_file="$data_dir/history.txt"
provider_select_file="$data_dir/provider.txt"

help_file="$config_dir/help.txt"
system_file="$config_dir/system.txt"

system_prompt=$(cat $system_file)

provider=$(cat $provider_select_file)
provider_file="$brunch_root/providers/$provider.sh"

api_key_file="$data_dir/keys/$provider.txt"
api_key=$(cat $api_key_file)

model_select_file="$data_dir/models/$provider.txt"
model=$(cat $model_select_file)

