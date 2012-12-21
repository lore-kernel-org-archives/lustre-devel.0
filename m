From: Liu, Xuezhao <Xuezhao.Liu@emc.com>
Date: Fri, 21 Dec 2012 08:44:08 -0500
Subject: [Lustre-devel] OFLAGS change.
In-Reply-To: <0746CF84-9748-4E86-9C45-088DFDACA40D@xyratex.com>
References: <D01411ED-E27A-4245-8614-86A69F168F95@xyratex.com>
	<CCF78FC7.BD6F%andreas.dilger@intel.com>
	<1882637210201641A747464075FFC6490715A2@MX101CL02.corp.emc.com>
	<8D7891D2-223E-4D47-99A3-6A40EE583439@xyratex.com>
	<AE8E737235CD0640B291384BFC2D8A354A3A7744@MX10A.corp.emc.com>
	<2A3EBFA8-6539-4378-B146-C0EC72CE6CF2@xyratex.com>
	<AE8E737235CD0640B291384BFC2D8A354A3A7807@MX10A.corp.emc.com>
	<0746CF84-9748-4E86-9C45-088DFDACA40D@xyratex.com>
Message-ID: <AE8E737235CD0640B291384BFC2D8A354A3A787D@MX10A.corp.emc.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I agree about that is change is good example - but focusing on vanila kernel development should be don't break something else, a specially add's problems with supporting a RHEL, SuSe.

[Xuezhao] Sure, we must ensure the added code will not break any supporting or to-be-supported vendor kernels, I will make a fixing patch if the break really happens.

>>
        # the implementation of cancel_dirty_page in OFED 1.4.1's SLES10 SP2
        # backport is broken, so ignore it
        if test -f $OFED_BACKPORT_PATH/linux/mm.h &&
           test "$(sed -ne '/^static inline void cancel_dirty_page(struct page \*page, unsigned int account_size)$/,/^}$/p' $OFED_BACKPORT_PATH/linux/mm.h | md5sum)" = "c518cb32d6394760c5bc
>>

that is from way you suggest.
that backport produce a live lock in lustre due impossible to have correct emulation for a cancel_dirty_pages in OFED.
and sometimes be easy create a implementation for old API via new when rewrite a lustre code to use new API and emulation for older kernels.

[Xuezhao] I may don't know the full story of the above case, but I understand your point. 
          OFED emulates new API based on old API on old kernel, and emulates linux API based on other OS' primitives on other OS. 
          But I think that in the above case it does not matter whether or not have the "cfs_" prefix, even if OFED has "ofd_cancel_dirty_page" it also cannot avoid the above.

Thanks,          
Xuezhao
