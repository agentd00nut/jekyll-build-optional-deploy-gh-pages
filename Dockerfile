FROM ruby:2.5.3	
ENV RUBYGEMS_VERSION=2.7.0
# Set default locale for the environment	
ENV LC_ALL C.UTF-8	
ENV LANG C.UTF-8	
ENV LANGUAGE C.UTF-8	

LABEL "com.github.actions.name"="Building a jekyll site from configured directory, maybe deploying it."	
LABEL "com.github.actions.description"="A more configurable jekyll repo builder with configurable deployment options."	
LABEL "com.github.actions.icon"="globe"	
LABEL "com.github.actions.color"="green"	

LABEL version="0.0.1"
LABEL repository="http://github.com/agentd00nut/jekyll-build-optional-deploy-gh-pages"	
LABEL maintainer="agentd00nut"

ADD entrypoint.sh /entrypoint.sh
# ENTRYPOINT ["/entrypoint.sh"]
ENTRYPOINT ["sh", "/entrypoint.sh"]
