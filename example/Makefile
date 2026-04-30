TARGET=vmadot

$(TARGET) : $(TARGET).c
	gcc $(TARGET).c -O3 -march=rv64gcv -o $(TARGET)

run: $(TARGET)
	./$(TARGET)

clean:
	rm -rf $(TARGET)
