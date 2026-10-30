git checkout main
git pull origin main
git checkout --orphan release

pushed=$(cat version.txt | head -n 1)
deployed=$(curl -s https://bashbrunch.attaditya.space/bashbrunch/version.txt | head -n 1)

if [ "$pushed" == "$deployed" ]; then
  echo "Releasing skipped"
  exit 0
fi

rm -rf .gitignore
rm -rf .github
rm -rf ci

find . -type f | sed 's|^\./||' | grep -v '^\.git' | grep -v '^files.txt' >> files.txt
find . -type d | sed 's|^\./||' | grep -v '^\.git' | grep -v '^\.$' >> dirs.txt

echo "data" >> dirs.txt
echo "data/keys" >> dirs.txt
echo "data/models" >> dirs.txt
echo "data/sessions" >> dirs.txt

ls providers | grep -o '^[^.]*' >> providers.txt

mkdir meta

mv files.txt meta/files.txt
mv dirs.txt meta/dirs.txt
mv providers.txt meta/providers.txt

git config user.name "Attachment Aditya"
git config user.email "attachment.aditya@gmail.com"

git add .
git commit -m "Release $pushed"
git push origin release --force

