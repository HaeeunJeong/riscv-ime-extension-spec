TARGET=vmadot_2mm_vd

$(TARGET) : $(TARGET).c
	gcc $(TARGET).c -O3 -march=rv64gcv -o $(TARGET)

ifeq ($(shell uname -m), riscv64)
run: $(TARGET)
	taskset -c 0 ./$(TARGET)
else
run:
	@echo "=========================================="
	@echo "🚀 Transferring source code to Banana Pi (bpi) board..."
	@echo "=========================================="
	ssh bpi 'mkdir -p ~/ime_workspace/example'
	scp $(TARGET).c Makefile bpi:~/ime_workspace/example/
	@echo "=========================================="
	@echo "⚙️  Starting native compilation and execution on the board..."
	@echo "=========================================="
	ssh bpi 'cd ~/ime_workspace/example && make clean && make run'
	@echo "=========================================="
	@echo "✅ Remote execution completed"
	@echo "=========================================="
endif

clean:
	rm -rf $(TARGET) $(TARGET).s

s:
	@echo "=========================================="
	@echo "🛠️  Generating assembly on the board..."
	@echo "=========================================="
	ssh bpi 'cd ~/ime_workspace/example && gcc $(TARGET).c -S -O3 -fno-unroll-loops -march=rv64gcv -o $(TARGET).s'
	@echo "=========================================="
	@echo "📥 Fetching assembly file to local server..."
	@echo "=========================================="
	scp bpi:~/ime_workspace/example/$(TARGET).s ./
	@echo "✅ Saved as $(TARGET).s"
