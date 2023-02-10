################
### Aliases
################

# Alias: CD Alviere code directory
alias cd-a="cd ~/code/mezu/repos/"
alias cd-i="cd ~/code/mezu/repos/infra"
alias cd-it="cd ~/code/mezu/repos/infra/terraform"
alias cd-itm="cd ~/code/mezu/repos/infra/terraform/modules"
alias cd-itd="cd ~/code/mezu/repos/infra/terraform/deploy"
alias cd-itda="cd ~/code/mezu/repos/infra/terraform/deploy/alviere"
alias cd-itaps="cd ~/code/mezu/repos/infra/terraform/aps"
alias cd-itask="cd ~/code/mezu/repos/infra/tasks"
alias cd-ih="cd ~/code/mezu/repos/infra/helm/"
alias cd-ihc="cd ~/code/mezu/repos/infra/helm/core"
alias cd-d="cd ~/code/mezu/repos/docker"

# Alias: kctx-env
alias kctx-dev-core="kubectx arn:aws:eks:us-west-2:041513908165:cluster/alv-dev002p-core-001"
alias kctx-dev-data="kubectx arn:aws:eks:us-west-2:041513908165:cluster/alv-dev002p-data-001"
alias kctx-dev-platform="kubectx arn:aws:eks:us-west-2:041513908165:cluster/alv-dev002p-platform-001"
alias kctx-stg-core="kubectx arn:aws:eks:us-west-2:989024148375:cluster/alv-stg002p-core-001"
alias kctx-stg-data="kubectx arn:aws:eks:us-west-2:989024148375:cluster/alv-stg002p-data-001"
alias kctx-snd-core="kubectx arn:aws:eks:us-west-2:695432702747:cluster/alv-snd002p-core-001"
alias kctx-snd-data="kubectx arn:aws:eks:us-west-2:695432702747:cluster/alv-snd002p-data-001"
alias kctx-prd-core="kubectx arn:aws:eks:us-west-2:486983068138:cluster/alv-prd002p-core-001"
alias kctx-prd-data="kubectx arn:aws:eks:us-west-2:486983068138:cluster/alv-prd002p-data-001"
alias kctx-dr="kubectx arn:aws:eks:us-east-1:486983068138:cluster/alv-prd002s-core-001"
alias kctx-gitlab="kubectx arn:aws:eks:us-east-1:730860714720:cluster/gitlab-eks001"
alias kctx-rancher="kubectx rancher-desktop"

# Alias: k9s
alias k9s-dev-core="k9s --context arn:aws:eks:us-west-2:041513908165:cluster/alv-dev002p-core-001 -A"
alias k9s-dev-data="k9s --context arn:aws:eks:us-west-2:041513908165:cluster/alv-dev002p-data-001 -A"
alias k9s-dev-platform="k9s --context arn:aws:eks:us-west-2:041513908165:cluster/alv-dev002p-platform-001 -A"
alias k9s-stg-core="k9s --context arn:aws:eks:us-west-2:989024148375:cluster/alv-stg002p-core-001 -A"
alias k9s-stg-data="k9s --context arn:aws:eks:us-west-2:989024148375:cluster/alv-stg002p-data-001 -A"
alias k9s-snd-core="k9s --context arn:aws:eks:us-west-2:695432702747:cluster/alv-snd002p-core-001 -A"
alias k9s-snd-data="k9s --context arn:aws:eks:us-west-2:695432702747:cluster/alv-snd002p-data-001 -A"
alias k9s-prd-core="k9s --context arn:aws:eks:us-west-2:486983068138:cluster/alv-prd002p-core-001 -A"
alias k9s-prd-data="k9s --context arn:aws:eks:us-west-2:486983068138:cluster/alv-prd002p-data-001 -A"
alias k9s-dr="k9s --context arn:aws:eks:us-east-1:486983068138:cluster/alv-prd002s-core-001 -A"
alias k9s-gitlab="k9s --context arn:aws:eks:us-east-1:730860714720:cluster/gitlab-eks001 -A"
alias k9s-rancher="k9s --context rancher-desktop"

################
### Functions
################

######## AWS

function alv-dms-start-tasks() {
if [[ $1 == '' ]] ; then
  echo "need env please"
else
  aws dms describe-replication-tasks --profile alv-$1 --no-paginate| jq -jr '.ReplicationTasks[] | .ReplicationTaskIdentifier, " ", .ReplicationTaskArn, " ", .Status,  "\n"' | while read task ; do
  task_status=$(echo $task | awk '{print $3}')
  task_arn=$(echo $task | awk '{print $2}')
  task_name=$(echo $task | awk '{print $1}')
  if [ $task_status == "stopped" ] || [ $task_status == "ready" ] || [ $task_status == "failed" ] ; then
    echo -e   "\033[0;31mStarting \033[0m$task_name has arn $task_arn with status $task_status"
    aws dms start-replication-task --replication-task-arn $task_arn --start-replication-task-type reload-target --profile alv-$1  > /dev/null 2>&1
    if [[ $2 != '' ]] ; then
      echo "waiting $2 before the starting the next task"
      sleep $2
    fi
  else
    echo -e "\033[0;32mSkipping\033[0m $task_name has arn $task_arn with status $task_status"
  fi
done
fi
}
