TARGET=pure_c_vd

# Check architecture
UNAME_M := $(shell uname -m)

ifeq ($(UNAME_M),riscv64)
    CC=gcc
    CFLAGS=-O3 -march=rv64gcv -ftree-vectorize
    EXEC=taskset -c 0 ./$(TARGET)
else
    CC=riscv64-unknown-linux-gnu-gcc
    CFLAGS=-O3 -march=rv64gcv -ftree-vectorize
endif

$(TARGET) : $(TARGET).c
	$(CC) $(TARGET).c $(CFLAGS) -o $(TARGET)

.PHONY: run s clean

run:
	@if [ "$(UNAME_M)" = "riscv64" ]; then \
		$(CC) $(TARGET).c $(CFLAGS) -o $(TARGET); \
		taskset -c 0 ./$(TARGET); \
	else \
		echo "Deploying to Banana Pi for execution..."; \
		ssh bpi 'mkdir -p ~/ime_workspace/c_mm'; \
		scp $(TARGET).c Makefile bpi:~/ime_workspace/c_mm/; \
		ssh bpi 'cd ~/ime_workspace/c_mm && gcc $(TARGET).c $(CFLAGS) -o $(TARGET) && taskset -c 0 ./$(TARGET)'; \
	fi

s:
	@if [ "$(UNAME_M)" = "riscv64" ]; then \
		$(CC) $(TARGET).c $(CFLAGS) -S -o $(TARGET).s; \
	else \
		echo "Generating assembly on Banana Pi and fetching..."; \
		ssh bpi 'mkdir -p ~/ime_workspace/c_mm'; \
		scp $(TARGET).c Makefile bpi:~/ime_workspace/c_mm/; \
		ssh bpi 'cd ~/ime_workspace/c_mm && gcc $(TARGET).c $(CFLAGS) -S -o $(TARGET).s'; \
		scp bpi:~/ime_workspace/c_mm/$(TARGET).s ./; \
	fi

clean:
	rm -f $(TARGET) $(TARGET).s
