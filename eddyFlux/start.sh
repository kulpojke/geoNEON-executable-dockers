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



docker build docker -t eddyr_docker && \
docker run --rm -it -v $SAVEPATH:/savepath -e USER=$USER -e HOME=/savepath -w /savepath eddyr_docker $DPID $PACKAGE $SITE $STARTDATE $ENDDATE

# ./start.sh /media/data/AOP/eddy TEAK 2019-06 2019-07