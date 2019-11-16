# Cortex-A72-Emulator
A Qemu-based Emulator for Cortex-A72 64-Bit Platform Running with Ubuntu 16.04.6 LTS (Xenial Xerus).


## How to Run

```bash
git clone https://github.com/ljishen/Cortex-A72-Emulator.git
cd Cortex-A72-Emulator
docker run -ti --rm \
    --mount type=bind,src=`pwd`/images,dst=/emu \
    [-e NUM_CPUS=X] [-e CPU_CORES=X] [-e CPU_THREADS=X] [-e CPU_SOCKETS=X] \
    [-e MEMORY=X] \
    -p 5555:22 \
    ljishen/cortex-a72-emulator
```

The default values of the system resource environment variables are:

```
# number of CPUs (<=8)
NUM_CPUS=8
# number of CPU cores on one socket (<=8)
CPU_CORES=8
# number of threads on one CPU core
CPU_THREADS=1
# number of discrete sockets in the system
CPU_SOCKETS=1
# initial amount of guest memory
MEMORY=12G
```
They should meet the cpu topology requirement: `sockets * cores * threads < smp_cpus`


## Size of the Disk Image

If you want to increase the size of the disk image, we can use `qemu-img resize`. For example, to increase the size to 34GB(= original 2GB + 32GB), we can do

```bash
qemu-img resize ubuntu-16.04-server-cloudimg-arm64-uefi1.img +32G
```

Note that you need to resize the image before launching the emulator.


## The Boot Process

The boot process starts with something like

```bash
error: no suitable video mode found.
error: no such device: root.

Press any key to continue...
EFI stub: Booting Linux Kernel...
EFI stub: Using DTB from configuration table
EFI stub: Exiting boot services and installing virtual address map...
[    5.327788] kvm [1]: HYP mode not available
```

Let the process continue until you see the finish of the execution of cloud-init
```bash
[  197.110907] cloud-init[1446]: Cloud-init v. 19.2-36-g059d049c-0ubuntu2~16.04.1 finished at Fri, 15 Nov 2019 05:14:37 +0000. Datasource DataSourceNoCloud [seed=/dev/vda][dsmode=net].  Up 196.72 seconds
```

And now you can login as user `ubuntu` with whatever the password (default: `passw0rd`), or via ssh from the host

```bash
ssh ubuntu@localhost -p 5555
```

You can then verify the system information:

```bash
ubuntu@ubuntu:~$ uname -a
Linux ubuntu 4.4.0-168-generic #197-Ubuntu SMP Wed Nov 6 11:15:24 UTC 2019 aarch64 aarch64 aarch64 GNU/Linux
ubuntu@ubuntu:~$
ubuntu@ubuntu:~$ lscpu
Architecture:          aarch64
Byte Order:            Little Endian
CPU(s):                6
On-line CPU(s) list:   0-5
Thread(s) per core:    1
Core(s) per socket:    6
Socket(s):             1
NUMA node(s):          1
NUMA node0 CPU(s):     0-5
ubuntu@ubuntu:~$
ubuntu@ubuntu:~$ free -mh
              total        used        free      shared  buff/cache   available
Mem:           7.8G         63M        7.5G        8.5M        213M        7.6G
Swap:            0B          0B          0B
ubuntu@ubuntu:~$
ubuntu@ubuntu:~$ df -h
Filesystem      Size  Used Avail Use% Mounted on
udev            3.9G     0  3.9G   0% /dev
tmpfs           798M  8.5M  790M   2% /run
/dev/vdb1        33G  1.3G   32G   4% /
tmpfs           3.9G     0  3.9G   0% /dev/shm
tmpfs           5.0M     0  5.0M   0% /run/lock
tmpfs           3.9G     0  3.9G   0% /sys/fs/cgroup
/dev/vdb15       98M  150K   98M   1% /boot/efi
tmpfs           798M     0  798M   0% /run/user/1000
```
