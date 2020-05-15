From: Shaun Tancheff <shaun@tancheff.com>
Date: Fri, 15 May 2020 14:58:55 -0500
Subject: [lustre-devel] Lustre ZFS OSD for Ubuntu/Debian
In-Reply-To: <CAKVGuZZLiC9kLt_LbQ880iZKsdTYD=svQHo4b7K58CkuP9p9Zw@mail.gmail.com>
References: <CAKVGuZZLiC9kLt_LbQ880iZKsdTYD=svQHo4b7K58CkuP9p9Zw@mail.gmail.com>
Message-ID: <CAJ48U8WMs0X-ygSCDNOz7QQDPpFt3rnX8rQhmWAxBVQNckxcJQ@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, May 15, 2020 at 7:24 AM Ankit Ladhania <ankit@tripock.com> wrote:
>
> Hi,
> I'm a newbie in Lustre and am trying to install it on top of ZFS. I'm using Ubuntu 16.04.
>
> I have installed the latest ZFS (built from source)
> zfs-0.8.4-1
> zfs-kmod-0.6.5.6-0ubuntu26
This combination doesn't make sense to me.

I would suggest following the ZFS package build:
https://github.com/openzfs/zfs/wiki/Building-ZFS
Ex:
cd
cd zfs
git clean -dfx
git checkout zfs-0.8.4
./autogen.sh
./configure --with-linux=/usr/src/linux-headers-5.4.0-29-generic
make deb
sudo dpkg -i kmod-zfs-5.4.0-29-generic_0.8.4-1_amd64.deb \
             kmod-zfs-devel_0.8.4-1_amd64.deb \
             kmod-zfs-devel-5.4.0-29-generic_0.8.4-1_amd64.deb \
             libnvpair1_0.8.4-1_amd64.deb \
             libuutil1_0.8.4-1_amd64.deb \
             libzfs2_0.8.4-1_amd64.deb \
             libzfs2-devel_0.8.4-1_amd64.deb \
             libzpool2_0.8.4-1_amd64.deb \
             python3-pyzfs_0.8.4-1_amd64.deb

sudo dpkg -i zfs_0.8.4-1_amd64.deb \
             zfs-dracut_0.8.4-1_amd64.deb \
             zfs-initramfs_0.8.4-1_amd64.deb \
             zfs-test_0.8.4-1_amd64.deb

cd
cd lustre-release

### NOTE. On 20.04 (fossa) I needed to change "libsnmp30" to "libsnmp35" in:
modified:   debian/control
modified:   debian/control.main
### ---

sh ./autogen.sh
./configure --enable-server --enable-client
--with-linux=/usr/src/linux-headers-5.4.0-29-generic
--with-zfs=/usr/src/zfs-0.8.4 --with-spl=/usr/src/spl-0.8.4
--disable-ldiskfs --enable-modules
make debs
cd debs
sudo dpkg -i lustre-server-modules-5.4.0-29-generic_2.12.58-928-ga9b9dd8-dirty-1_amd64.deb
\
             lustre-server-utils_2.12.58-928-ga9b9dd8-dirty-1_amd64.deb \
             lustre-tests_2.12.58-928-ga9b9dd8-dirty-1_amd64.deb \
             lustre-iokit_2.12.58-928-ga9b9dd8-dirty-1_amd64.deb \
             lustre-resource-agents_2.12.58-928-ga9b9dd8-dirty-1_amd64.deb

From there you need to create at least 2 pools.
1 pool can be mgs+mdt
1 pool will be ost

Here I let lustre create the pools underneath, ymmv:

sudo modprobe brd rd_nr=2 rd_size=$((1024*600))
lsblk /dev/ram0 /dev/ram1
NAME MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
ram0   1:0    0  600M  0 disk
ram1   1:1    0  600M  0 disk

ip addr says my ethernet is 'enp1s0' with ip: 192.168.122.208 so setup lnet:

As root:
# echo "options lnet networks=tcp0(enp1s0)">/etc/modprobe.d/lnet.conf
# systemctl enable lnet.service
# systemctl start lnet

# Create the mgs/mdt
sudo mkfs.lustre --mdt --mgs --fsname=lustre --backfstype=zfs
--index=0 lustre-mdt0/mdt0 ram0
# Create the ost
sudo mkfs.lustre --ost --backfstype=zfs --fsname=lustre --index=0
--mgsnode=192.168.122.208 at tcp0 lustre-ost0/ost0 ram1

# Make a place to mount them:
sudo mkdir /mnt/lustre-mdt0
sudo mkdir /mnt/lustre-ost0

# Mount them
sudo mount -t lustre lustre-mdt0/mdt0 /mnt/lustre-mdt0
sudo mount -t lustre lustre-ost0/ost0 /mnt/lustre-ost0

# Test the client:
sudo mkdir /mnt/lustre
sudo mount -t lustre 192.168.122.208 at tcp0:/lustre /mnt/lustre

Hope this helps


> I have installed the latest Lustre (built from source):
> lustre-dev_2.12.4-60-g8ecf56c-1_amd64.deb
> lustre-iokit_2.12.4-60-g8ecf56c-1_amd64.deb
> lustre-resource-agents_2.12.4-60-g8ecf56c-1_amd64.deb
> lustre-server-modules-4.4.0-142-generic_2.12.4-60-g8ecf56c-1_amd64.deb
> lustre-server-utils_2.12.4-60-g8ecf56c-1_amd64.deb
> lustre-source_2.12.4-60-g8ecf56c-1_all.deb
> lustre-tests_2.12.4-60-g8ecf56c-1_amd64.deb
>
> As per the doc I have created zpool:
> $ sudo zpool create  -fd -O canmount=off  mgspool mirror /dev/sdb /dev/sdc
>
> then:
> $ sudo mkfs.lustre --reformat --fsname=zeblok --mgs --servicenode=130.245.177.196 at tcp --backfstype=zfs --verbose mgspool/mgt
>
> when I'm trying to mount the file system:
> $ sudo mount -t lustre mgspool/mgt /mnt/mdt
> mount.lustre: mgspool/mgt is configured for failover but zpool does not have multihost enabled
> mount.lustre: mgspool/mgt is configured for failover but zpool does not have multihost enabled
> mount.lustre: mount mgspool/mgt at /mnt/mdt failed: No such device
> Are the lustre modules loaded?
> Check /etc/modprobe.conf and /proc/filesystems
>
> In dmesg I'm getting the below error:
> LustreError: 158-c: Can't load module 'osd-zfs'
> [836981.548061] LustreError: 30106:0:(genops.c:397:class_newdev()) OBD: unknown type: osd-zfs
> [836981.669172] LustreError: 30106:0:(obd_config.c:403:class_attach()) Cannot create device MGS-osd of type osd-zfs : -19
> [836981.790888] LustreError: 30106:0:(obd_mount.c:197:lustre_start_simple()) MGS-osd attach error -19
> [836981.913181] LustreError: 30106:0:(obd_mount_server.c:1956:server_fill_super()) Unable to start osd on mgspool/mgt: -19
> [836982.035378] LustreError: 30106:0:(obd_mount.c:1608:lustre_fill_super()) Unable to mount  (-19)
>
> I see that in centos there is a rpm that is asked to install:
>
> lustre-osd-zfs-mount
>
> What is the alternative in debian?
>
> Thanks for all the help.
>
>
> Regards,
> Ankit Ladhania
> IN: +91 933 444 2209
> US:  +1 (256) 203-0077
> Skype: ankit.ladhania
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
