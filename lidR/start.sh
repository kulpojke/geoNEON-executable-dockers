
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

DATAPATH=$1
OUTPATH=$2

docker build docker -t lidr_docker && \
docker run --rm -it -v $PWD:/data -v $DATAPATH:/datapath -v $OUTPATH:/outpath -e USER=$USER -e HOME=/data -w /data lidr_docker

# ./start.sh /media/data/AOP/data/laz /media/data/AOP/out