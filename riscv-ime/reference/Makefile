BUILDDIR ?= build

T ?= uint32_t

PRINT ?= 0

#COMMON_FLAGS := -Wall -Wextra -Werror -g 
#-I${COMMON_INCLUDES}
HOST_FLAGS := ${COMMON_FLAGS} -O3 -DNR_TASKLETS=${NR_TASKLETS} -DNR_DPUS=${NR_DPUS} -DDPU_BINARY=\"${DPU_BINARY}\" `dpu-pkg-config --cflags --libs dpu` -DT=${T} -DPRINT=${PRINT} -g

all: clean prep data_dir

data_dir: 
	mkdir -p dataset

prep:
	gcc -o prep.exe prep.c -fopenmp ${HOST_FLAGS};

clean:
	rm -rf prep.exe
