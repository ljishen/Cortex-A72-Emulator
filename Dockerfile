FROM alpine:3 AS builder
LABEL maintainer="jliu120@ucsc.edu"
LABEL edu.ucsc.version="0.0.1"

RUN apk add --no-cache \
    --repository \
    http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    cloud-utils

RUN addgroup -g 1000 -S cloud-init && \
    adduser -u 1000 -S cloud-init -G cloud-init
USER cloud-init

WORKDIR /tmp
COPY configs ./
RUN cloud-localds seed.img user-data meta-data


FROM alpine:3

RUN apk add --no-cache \
    qemu-system-aarch64

COPY --from=builder /tmp/seed.img /
WORKDIR /emu

# type of CPU
ENV CPU cortex-a72
# number of CPUs (<=8)
ENV NUM_CPUS 8
# number of CPU cores on one socket (<=8)
ENV CPU_CORES 8
# number of threads on one CPU core
ENV CPU_THREADS 1
# number of discrete sockets in the system
ENV CPU_SOCKETS 1
# initial amount of guest memory
ENV MEMORY 12G

# hostfwd=tcp::22-:22 is required to map the guestport to the port within the container
ENTRYPOINT ["sh", "-c", \
            "qemu-system-aarch64 \
            -machine type=virt \
            -cpu $CPU \
            -smp cpus=$NUM_CPUS,maxcpus=$NUM_CPUS,cores=$CPU_CORES,threads=$CPU_THREADS,sockets=$CPU_SOCKETS \
            -m size=$MEMORY \
            -nographic \
            -bios QEMU_EFI.fd \
            -drive if=none,file=ubuntu-16.04-server-cloudimg-arm64-uefi1.img,id=hd0 \
            -device virtio-blk-device,drive=hd0 \
            -drive if=none,file=/seed.img,id=seed,format=raw \
            -device virtio-blk-device,drive=seed \
            -netdev user,id=user0,hostfwd=tcp::22-:22 \
            -device virtio-net,netdev=user0"]
CMD ["$@"]
