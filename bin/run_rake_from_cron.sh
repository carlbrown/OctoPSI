#!/bin/sh

PARENTDIR="${HOME}/Documents/Sites/"

# If you have other stuff in the parent directory or some blog dirs have spaces, you might want to hardcode this
OCTOPRESS_BLOG_DIRS="`ls -1 ${PARENTDIR}`"

cd "${PARENTDIR}"

for blog in ${OCTOPRESS_BLOG_DIRS}; do
	cd ${blog}
	latest_public_file="`ls -1tr public/ | tail -1`"
	newer_files="`find source -type f -newer public/${latest_public_file}`"
	if [ ! -z "${newer_files}" ] ; then
		# Some file in source is newer than the most recent thing in public
		git add source
		git commit -a -m "Dynamically generated content"
		git push origin master
		
		# Generate and push the new site
		rake generate
		if [ $? -eq 0 ] ; then
			rake deploy
		fi
	fi
	cd ..
done