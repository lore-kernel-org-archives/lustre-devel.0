From: Chris J Arges <chris.j.arges@canonical.com>
Date: Fri, 6 Nov 2015 18:38:04 -0600
Subject: [lustre-devel] Build Dependency Issue in Lustre Mainline Linux
In-Reply-To: <9c0ab2c280eb401f88d0ffd57ec3987b@EXCHCS32.ornl.gov>
References: <563BB5D7.2040506@canonical.com>
	<9c0ab2c280eb401f88d0ffd57ec3987b@EXCHCS32.ornl.gov>
Message-ID: <563D47EC.6080909@canonical.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 11/06/2015 06:10 PM, Simmons, James A. wrote:
> 
>> Just did a fresh git pull --rebase and tried to do 'make deb-pkg' with
>> an Ubuntu config (which enables lustre). I got the following:
>>
>> depmod: WARNING: found 2 modules in dependency cycles!
>> depmod: WARNING:
>> /home/arges/src/kernel/linux/./debian/tmp/lib/modules/4.3.0+/kernel/drivers/staging/lustre/lnet/lnet/lnet.ko
>> in dependency cycle!
>> depmod: WARNING:
>> /home/arges/src/kernel/linux/./debian/tmp/lib/modules/4.3.0+/kernel/drivers/staging/lustre/lustre/libcfs/libcfs.ko
>> in dependency cycle!
>> ./scripts/depmod.sh: line 57: 16836 Killed                  "$DEPMOD"
> 
> I solved your problem. If you delete IOC_LIBCFS_PING_TEST ioctl case  from libcfs/libcfs/module.c it work again. 
> That ioctl has not been is use for some time and it can be removed. What is happening is libcfs_nid2str is being
> called which requires lnet.ko now. This is a layer violation. I will be sending a patch very shortly.
> 

Thanks, good to hear.
--chris
