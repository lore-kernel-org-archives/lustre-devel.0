From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Thu, 5 Nov 2015 22:10:01 +0000
Subject: [lustre-devel] Build Dependency Issue in Lustre Mainline Linux
In-Reply-To: <563BB5D7.2040506@canonical.com>
References: <563BB5D7.2040506@canonical.com>
Message-ID: <D261223F.118B92%andreas.dilger@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2015/11/05, 13:02, "lustre-devel on behalf of Chris J Arges"
<lustre-devel-bounces at lists.lustre.org on behalf of
chris.j.arges@canonical.com> wrote:

>Just did a fresh git pull --rebase and tried to do 'make deb-pkg' with
>an Ubuntu config (which enables lustre). I got the following:
>
>depmod: WARNING: found 2 modules in dependency cycles!
>depmod: WARNING:
>/home/arges/src/kernel/linux/./debian/tmp/lib/modules/4.3.0+/kernel/driver
>s/staging/lustre/lnet/lnet/lnet.ko
>in dependency cycle!
>depmod: WARNING:
>/home/arges/src/kernel/linux/./debian/tmp/lib/modules/4.3.0+/kernel/driver
>s/staging/lustre/lustre/libcfs/libcfs.ko
>in dependency cycle!
>./scripts/depmod.sh: line 57: 16836 Killed                  "$DEPMOD"
>"$@" "$KERNELRELEASE" $SYMBOL_PREFIX
>make[2]: *** [_modinst_post] Error 137
>make[1]: *** [deb-pkg] Error 2
>make: *** [deb-pkg] Error 2
>
>This was building fine in v4.3, so I suspect something after this tag is
>causing issue. (My HEAD is at 8e483ed13).

Could you run git bisect to find the offending patch?  The error messages
don't really give very much to go on.

Cheers, Andreas
-- 
Andreas Dilger

Lustre Software Architect
Intel High Performance Data Division
