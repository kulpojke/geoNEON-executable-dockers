while getopts ":h" option; do
   case $option in
      h) # display Help
        echo "SYNOPSIS"  
        echo "     has args"
        echo "DESCRIPTION"
        echo "     does things"
        exit;;
   esac
done

SAVEPATH=$1
DPID='DP4.00200.001'
PACKAGE='basic' 
SITE=$2
STARTDATE=$3
ENDDATE=$4



docker build docker_scratch -t eddyr_docker_scratch && \
docker run --rm -it -v $PWD:/data -v $SAVEPATH:/savepath -e USER=$USER -e HOME=/data -w /data eddyr_docker_scratch

# ./start_scratch.sh /media/data/AOP/eddy 