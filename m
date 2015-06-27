From: Drokin, Oleg <oleg.drokin@intel.com>
Date: Sat, 27 Jun 2015 13:26:14 +0000
Subject: [lustre-devel] lustre: broken/old urls in the code
In-Reply-To: <558E5174.1050202@gmail.com>
References: <558E5174.1050202@gmail.com>
Message-ID: <B235BB96-6B39-4FB9-979C-6906574AB329@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Jun 27, 2015, at 3:32 AM, Xose Vazquez Perez wrote:

> Hi,
> 
> You should replace old and broken urls.

Of the URLs you quoted the only five old URLs that are not working are:
http://www.sun.com/software/products/lustre/docs/GPLv2.pdf - this one is part of old standard GPL header.
That copyright was bought by Oracle then by Xyratex and then by Seagate. We do not own it and we felt at the
time we don't really have any rights to change it. That's why it stays like that.

http://wiki.lustre.org/index.php/Architecture_-_Interoperability_fids_zfs - this does not seem to work indeed
and we need to find where it was moved to.
Same deal with arch.lustre.org

http://www.xyratex.com/contact is no more and is part of Seagate now, but I guess it's part of come copyright header
and so unchangeable all that easily?

The rest seem to be working just fine.

lustre.org is valid and is not old. Same with opensfs.

whamcloud* is deprecated but the proper redirects are in place, so I guess we can change them to the new location.




> 
> querida:/mnt/datos/kernel/linux/drivers/staging/lustre $ egrep -ir "http|ftp:" *  -h | sort  | uniq -c | sort -nr
>    275  * This file is part of Lustre, http://www.lustre.org/
>    253  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
>     14 MODULE_AUTHOR("Sun Microsystems, Inc. <http://www.lustre.org/>");
>     10  * http://www.gnu.org/licenses/gpl-2.0.html
>      6  * version 2 along with this program; If not, see http://www.gnu.org/licenses
>      4  * Please  visit http://www.xyratex.com/contact if you need additional
>      2  *   This file is part of Portals, http://www.sf.net/projects/sandiaportals/
>      2           See also http://wiki.lustre.org/
>      2  * http://www.gnu.org/licenses/gpl-2.0.txt
>      2  *   http://sourceforge.net/projects/sandiaportals/
>      1  * with this program.  If not, see <http://www.gnu.org/licenses/>.
>      1  *   This file is part of Portals, http://www.sf.net/projects/lustre/
>      1  *   This file is part of Lustre, http://www.lustre.org.
>      1  *   This file is part of Lustre, http://www.lustre.org
>      1 OpenSFS website: http://lustre.opensfs.org/about/
>      1         LCONSOLE_INFO("Echo OBD driver; http://www.lustre.org/\n");
>      1 Intel HPDD wiki: https://wiki.hpdd.intel.com
>      1                          "inode=%lu/%u(%p) nrpages=%lu, see http://jira.whamcloud.com/browse/LU-118\n",
>      1  * http://www.citi.umich.edu/techreports/reports/citi-tr-00-1.pdf
>      1  * http://wiki.lustre.org/index.php/Architecture_-_Interoperability_fids_zfs
>      1 https://downloads.hpdd.intel.com/public/lustre/latest-feature-release/
>      1 http://lustre.opensfs.org/download-lustre/
>      1           http://git.whamcloud.com/?p=fs/lustre-release.git;a=summary
>      1 http://git.whamcloud.com/fs/lustre-release.git
>      1           http://downloads.whamcloud.com/public/lustre/
>      1  * http://arch.lustre.org/index.php?title=Interoperability_fids_zfs#NEW.0
>      1  * http://arch.lustre.org/index.php?title=Interoperability_fids_zfs
>      1                         CWARN("Saw flags 0x%x and 0x%x in the same brw, please report this at http://bugs.whamcloud.com/\n",
>      1                 CERROR("%s went back in time (transno %lld was previously committed, server now claims %lld)!  See https://bugzilla.lustre.org/show_bug.cgi?id=9646\n",
> 
> -thanks-
