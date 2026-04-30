TARGET=vmadot

$(TARGET) : $(TARGET).c
	gcc $(TARGET).c -O3 -march=rv64gcv -o $(TARGET)

run: $(TARGET)
	taskset -c 0 ./$(TARGET)

clean:
	rm -rf $(TARGET)
