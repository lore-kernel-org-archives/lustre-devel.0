From: Xuezhao.Liu at emc.com <Xuezhao.Liu@emc.com>
Date: Wed, 29 Feb 2012 03:29:15 -0500
Subject: [Lustre-devel] For ptlrpc and related modules cleanup
In-Reply-To: <20120221205129.GA25762@granier.hd.free.fr>
References: <7601FECF1C5EDF4AA5A446AB4B08BB510125A785B3@MX25A.corp.emc.com>
	<7601FECF1C5EDF4AA5A446AB4B08BB510125A787D6@MX25A.corp.emc.com>
	<F6EC8E93-996A-4067-8830-E48BAB64580A@whamcloud.com>
	<20120221205129.GA25762@granier.hd.free.fr>
Message-ID: <7601FECF1C5EDF4AA5A446AB4B08BB510125D0782C@MX25A.corp.emc.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Johann,

As we only need to compile lquota module and defines HAVE_QUOTA_SUPPORT as 1 when Lustre is configured without ?--disable-server? option and without ?--enable-quota=no? option.
So indeed all HAVE_QUOTA_SUPPORT macros inside all source files of lustre/quota can be removed to make the code looks clean. (indeed we only compile lustre/quota in the case HAVE_QUOTA_SUPPORT is defined as 1).

And there are some function declarations inside quota_internal.h -- client_quota_adjust_qunit, lov_quota_adjust_qunit etc., neither they have function body nor have callers. So these declarations can be removed. (or has other reasons to remain them?)

This email can be ignored if I am correct and please correct me if I am wrong. Thanks!

Best Regards,
Xuezhao
-----Original Message-----
From: lustre-devel-bounces@lists.lustre.org [mailto:lustre-devel-bounces at lists.lustre.org] On Behalf Of Johann Lombardi
Sent: 2012?2?22? 4:51
To: Andreas Dilger
Cc: Tang, Haiying; lustre-devel at lists.opensfs.org; Bryon Neitzel; Liu, Xuezhao; faibish, sorin; Lustre Devel
Subject: Re: [Lustre-devel] For ptlrpc and related modules cleanup

On Tue, Feb 21, 2012 at 01:02:25PM -0700, Andreas Dilger wrote:
> I think this list of tasks looks reasonable.  Johann should comment on the lquota module changes, since there is a considerable amount of other work being done on that code, and the changes being made should be coordinated to avoid conflict.

As of 2.2, the lquota module isn't needed on the client side any more (see http://review.whamcloud.com/#change,1613). I would thus be delighted if this module isn't built with --disable-server, as suggested in the document.

Johann
-- 
Johann Lombardi
Whamcloud, Inc.
www.whamcloud.com
_______________________________________________
Lustre-devel mailing list
Lustre-devel at lists.lustre.org
http://lists.lustre.org/mailman/listinfo/lustre-devel
