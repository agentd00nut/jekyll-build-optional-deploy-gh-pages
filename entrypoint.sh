#!/bin/sh

echo "[!] - Entrypoint has started";

# Should we go up a dir before exiting?
die(){
	if [ -n "$JEKYLL_ROOT" ]; then
		cd ../
	fi
}

# Where should we try to do all of this?
if [ -z "$JEKYLL_ROOT" ]; then
  echo "[!] - JEKYLL_ROOT is not set. Going to try and build the root dir."
else
	if [ ! -d "${JEKYLL_ROOT}" ]; then
		echo "[!!!!] - ${JEKYLL_ROOT} not found, exiting!"
		exit 1;
	fi

  	cd "${JEKYLL_ROOT}";

fi

# Whats the gemfile called?
if [ -z "$GEMFILE" ]; then
	echo "[!] - Gemfile not defined; defaulting to GemFile";
	GEMFILE="Gemfile";
fi
if [ ! -f "$GEMFILE" ]; then
	echo "[!!!!] - ${GEMFILE} not found - exiting";
	die
	exit 1
fi


# Should we delete the gemlock when building?
if [ -n "$REMOVE_GEMLOCK" ] && [ "$REMOVE_GEMLOCK" = true ]; then
	echo "[!] - Removing Gemlock."
	rm Gemfile.lock > /dev/null 2>&1
fi

# Should we deploy the site?
if [ -z "$DEPLOY_SITE" ]; then	
	echo "[!] - DEPLOY_SITE is not set.  Defaulting to 'true'";
	DEPLOY_SITE=true
fi

# Set options if we're going to try and deploy the site.

if [ "$DEPLOY_SITE" = true ]; then

	# Where is the site going to get built into?
	if [ -z "$BUILD_DIR" ]; then
	  echo "[!] - BUILD_DIR is not set. Assuming the site is building to _site/"
	  BUILD_DIR="_site/";
	fi

	# What branch do we want to push the build dir to?
	if [ -z "$REMOTE_BRANCH" ]; then
	  echo "[!] - REMOTE_BRANCH is not set. Assuming we want to push the built site into gh-pages"
	  REMOTE_BRANCH="gh-pages";
	fi
fi


echo '[!] - SPECIAL WORKFLOW - installing bundler 1.17.1'
gem install jekyll bundler:1.17.1

echo '[!] - Installing Gem Bundle'
bundle install

echo '[!] - SPECIAL WORKFLOW - installing execjs'
gem install execjs

echo '[!] - SPECIAL WORKFLOW - installing therubyracer'
gem install therubyracer

echo -n '[!] - Jekyll Version: '
bundle list | grep "jekyll ("

if [ -n "$DELETE_BEFORE_BUILD" ]; then
	echo -n "[!] - Deleting ${DELETE_BEFORE_BUILD}"
	rm -rf ${DELETE_BEFORE_BUILD};
fi

echo '[!] - SPECIAL WORKFLOW - updating apt-get trying to install nodejs'
apt-get update
apt-get -y install nodejs


echo '[!] - Building -- with future!'
bundle exec jekyll build --future



if [ "$DEPLOY_SITE" = true ]; then	
	
	echo "[!] - Pushing the contents of ${BUILD_DIR} to ${REMOTE_BRANCH}"
	
	if [ ! -d "${BUILD_DIR}" ]; then
		echo "[!!!!] - ${BUILD_DIR} Not Found, Exiting"
		die
		exit 1
	fi
	
	cd "${BUILD_DIR}"
	remote_repo="https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git" && \
	remote_branch="${REMOTE_BRANCH}" && \
	
	git init && \
	git config user.name "${GITHUB_ACTOR}" && \
	git config user.email "${GITHUB_ACTOR}@users.noreply.github.com" && \
	git add . && \
	
	echo -n '[!] - Files to Commit:' && ls -l | wc -l && \
	
	git commit -m'action build' > /dev/null 2>&1 && \
	git push --force $remote_repo master:$remote_branch > /dev/null 2>&1 && \
	
	rm -fr .git && \
	
	cd ../
fi

echo '[!] - EntryPoint has finished.'
die
exit

