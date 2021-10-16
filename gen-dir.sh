input_file=$1
output_dir=$2

fields=$(yq --raw-output '. |= keys | @csv' "${input_file}" | tr ',' '\n' | sed -e 's/"//g')
for field in $fields; do
  yq --raw-output --yaml-output ".$field" "${input_file}" >> "${output_dir}/${field}.yaml"
done;
