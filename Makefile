# @author Vyacheslav Lapin aka "C'est la vie". 2021 (c) http://vlapin.ru
# This Makefile is written as command-line Project API for Java Maven multi-module
# projects with Lombok annotation processor. Required software list:
# - Maven, Git, JDK
# - JEnv - for *nix/Mac only!
# - XMLStarlet Toolkit
# - XsltProc

# For Windows cmd users:
# - Comment or delete the JEnv block in "init" task
# - Delete "./" substring in some commands, like ./mvnw verify - it should looks like "mvnw verify"
# - Replace "ln" with "mklink" command (see https://stackoverflow.com/questions/17246558/what-is-the-windows-equivalent-to-the-ln-s-target-folder-link-folder-unix-s)

#--------------------------
#Variables:

# Project GroupId
PG=`cat pom.xml | xml sel -N pom=http://maven.apache.org/POM/4.0.0 -t -v /pom:project/pom:groupId`

# Main package
MP=`cat pom.xml | xml sel -N pom=http://maven.apache.org/POM/4.0.0 -t -v /pom:project/pom:groupId | tr '.' '/'`

# Project Artifact id
PA=`cat pom.xml | xml sel -N pom=http://maven.apache.org/POM/4.0.0 -t -v /pom:project/pom:artifactId`

# Project Version
PV=`cat pom.xml | xml sel -N pom=http://maven.apache.org/POM/4.0.0 -t -v /pom:project/pom:properties/pom:revision`

# Maven Version
MV=3.8.4

# Java Version
J=`cat pom.xml | xml sel -N pom=http://maven.apache.org/POM/4.0.0 -t -v /pom:project/pom:properties/pom:java.version`


# Lombok Version
LV=`cat pom.xml | xml sel -N pom=http://maven.apache.org/POM/4.0.0 -t -v /pom:project/pom:properties/pom:lombok.version`

#--------------------------
#Tasks:

init-project:
	../../commons/spring-boot/monolith/make project-init P=`pwd` PG=$(PG) MP=$(MP) PA=$(PA) PV=$(PV) J=$(J)

init:
	git init
	touch .git/info/exclude

#	maven-wrapper
	mvn -N io.takari:maven:wrapper -Dmaven=$(MV)
	rm mvnw.cmd
	chmod +x ./mvnw
	echo "\n/.mvn\n/mvnw*\n" >> .git/info/exclude

#	jenv
	jenv local $(J)
	echo "\n/.java-version\n" >> .git/info/exclude

#	checkstyler
#	There is a problem with it. See: https://stackoverflow.com/questions/57723278/maven-checkstyle-plugin-does-not-execute-on-custom-rules
#	curl -O https://raw.githubusercontent.com/checkstyle/checkstyle/master/src/main/resources/google_checks.xml
	curl -O https://raw.githubusercontent.com/checkstyle/checkstyle/checkstyle-8.12/src/main/resources/google_checks.xml
	echo "\n/google_checks.xml\n" >> .git/info/exclude

uninit:
	rm -rf .mvn mvnw* google_checks.xml .git/info/exclude .java-version

reboot: clear uninit init

uninit-full: clear uninit
	rm -rf .idea $(PA).iml .git

reboot-full: uninit-full init
	echo "\n/.idea/\n/$(PA).iml\n/out/\n/classes/\n" >> .git/info/exclude
	git add src .editorconfig .gitignore Makefile pom.xml README.md
	idea pom.xml

jshell:
	jshell --enable-preview --start PRINTING --start JAVASE --class-path `mvn dependency:build-classpath | grep -A1 'Dependencies classpath' | tail -1`

build:
	./mvnw verify
	chmod +x ./target/$(PA)-$(PV).jar

run:
	./mvnw spring-boot:run -Dspring.profiles.active=local
#	./target/$(PA)-$(PV).jar
#	java -jar --enable-preview ./target/$(PA)-$(PV)-jar-with-dependencies.jar

effective-pom:
	./mvnw help:effective-pom

clear:
	./mvnw clean

test: clear
	./mvnw test

update:
	./mvnw versions:update-parent versions:update-properties versions:display-plugin-updates

delombok: clear
	./mvnw lombok:delombok
#	mkdir -p ./target/generated-sources/delombok
#	java -cp `./mvnw dependency:build-classpath | grep -A1 'Dependencies classpath' | tail -1` \
#		lombok.launch.Main delombok ./src/main/java \
#		-d ./target/generated-sources/delombok

test-delombok: delombok
	./mvnw lombok:testDelombok
#	mkdir -p ./target/generated-test-sources/delombok
#	java -cp `./mvnw dependency:build-classpath | grep -A1 'Dependencies classpath' | tail -1`:./target/generated-sources/delombok \
#		lombok.launch.Main delombok ./src/test/java \
#		-d ./target/generated-test-sources/delombok

#	see: https://stackoverflow.com/questions/7244321/how-do-i-update-a-github-forked-repository
git-fork-init: init
#	Add the remote, call it "upstream":
	git remote add upstream git://$gitHost$/$(PA).git

#	Fetch all the branches of that remote into remote-tracking branches, such as upstream/master:
	git fetch upstream

#	Make sure that you're on your master branch:
	git checkout master

#	Rewrite your master branch so that any commits of yours that aren't already in upstream/master are replayed on top of that other branch:
	git rebase upstream/master

#branch name
B=feature
git-branch:
	git checkout -b $(B)
	git push -u origin $(B)

.DEFAULT_GOAL := build-run
build-run: update build run
  