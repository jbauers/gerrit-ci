tmp_dir=$(mktemp -d)
clean() {
  cd /tmp
  rm -rf $tmp_dir
}
trap clean EXIT

cd $tmp_dir

git config --global user.name "Gerrit CI" 
git config --global user.email "gerrit@$(hostname)"

git clone '/var/gerrit/git/All-Projects.git' && cd "All-Projects"
GIT_WORK_TREE="${PWD}"

git remote add local /var/gerrit/git/All-Projects.git
git fetch -q local refs/meta/config:refs/remotes/origin/meta/config
git checkout meta/config

git config -f project.config label.Verified.function MaxWithBlock
git config -f project.config --add label.Verified.defaultValue  0
git config -f project.config --add label.Verified.value "-1 Fails"
git config -f project.config --add label.Verified.value "0 No score"
git config -f project.config --add label.Verified.value "+1 Verified"
git commit -a -m "Added label - Verified"

git config -f project.config --unset access.refs/*.read "group Anonymous Users"
git config -f project.config --add access.refs/heads/*.read "group Non-Interactive Users"
git config -f project.config --add access.refs/tags/*.read "group Non-Interactive Users"
git config -f project.config --add access.refs/heads/*.label-Code-Review "-1..+1 group Non-Interactive Users"
git config -f project.config --add access.refs/heads/*.label-Verified "-1..+1 group Non-Interactive Users"
git config -f project.config --add access.refs/heads/*.label-Verified "-1..+1 group Project Owners"
git commit -a -m "Change access right." -m "Add access right for CI. Remove anonymous access right"

git push local meta/config:meta/config
