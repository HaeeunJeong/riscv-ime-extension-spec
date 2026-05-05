# 빌드해둔 LLVM 17 Clang 경로 지정
CC := /home/haeeun/Applications/llvm-project/build/bin/clang

# 컴파일 플래그
# -mamx-tile -mamx-int8: AMX 기능 활성화
CFLAGS = -O2 -mamx-tile -mamx-int8 -march=native -Wall

TARGETS = amx_test amx_vd_abstract_test

.PHONY: all run clean ir asm

all: $(TARGETS)

# 실행 파일 빌드
amx_test: amx_test.c
	$(CC) $(CFLAGS) $< -o $@

amx_vd_abstract_test: amx_vd_abstract_test.c
	$(CC) $(CFLAGS) $< -o $@

# 컴파일 후 실행
run: all
	./amx_vd_abstract_test

# LLVM IR 생성 (.ll 파일)
ir: amx_test.ll amx_vd_abstract_test.ll

%.ll: %.c
	$(CC) $(CFLAGS) -S -emit-llvm $< -o $@

# 어셈블리 생성 (.s 파일)
s: amx_test.s amx_vd_abstract_test.s

%.s: %.c
	$(CC) $(CFLAGS) -S $< -o $@

clean:
	rm -f $(TARGETS) *.ll *.s
