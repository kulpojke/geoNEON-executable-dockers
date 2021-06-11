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
docker run --rm -it  -v $SAVEPATH:/home/rstudio/data -w /home/rstudio/data -p 8786:8787 -e USERID=$UID -e PASSWORD=passwd  eddyr_docker_scratch

# the -e USERID=$UID above is what finally allowed rstudio permissions in the volume

# ./start_scratch.sh /data/mthuggin/eddy2
# then in new terminal
# ssh -NL localhost:1255:localhost:8786  mthuggin@elcapitan.csc.calpoly.edu
