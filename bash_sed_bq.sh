FILES=~/Documents/r-projects/cr_dump/data_parsed/data_parsed/*
for i in $FILES; do
    sed -i '' 's/container.title/container_title/g' $i
    sed -i '' 's/published.print/published_print/g' $i
    sed -i '' 's/published.online/published_online/g' $i
    sed -i '' 's/reference.count/reference_count/g' $i
    sed -i '' 's/is.referenced.by.count/is_referenced_by_count/g' $i
    sed -i '' 's/delay.in.days/delay_in_days/g' $i
    sed -i '' 's/content.version/content_version/g' $i
    sed -i '' 's/content.type/content_type/g' $i
    sed -i '' 's/intended.application/intended_application/g' $i
    echo "Processing $i"
done
