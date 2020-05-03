FILES=data_parsed/*
for i in $FILES; do
    sed -i '' 's/container.title/container_title/g' $i
    sed -i '' 's/delay.in.days/delay_in_days/g' $i
    sed -i '' 's/content.version/content_version/g' $i
    sed -i '' 's/content.type/content_type/g' $i
    sed -i '' 's/intended.application/intended_application/g' $i
    echo "Processing $i"
done