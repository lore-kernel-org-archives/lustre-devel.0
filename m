From: tao.peng at emc.com <tao.peng@emc.com>
Date: Mon, 30 Jan 2012 02:46:14 -0500
Subject: [Lustre-devel] Lustre dcache clean up and distributed locking
In-Reply-To: <4F19A01B.4070405@whamcloud.com>
References: <F19688880B763E40B28B2B462677FBF805E7E684CD@MX09A.corp.emc.com>
	<AC57B2B9-5559-4713-905D-7AC9BAE3B1DB@whamcloud.com>
	<F19688880B763E40B28B2B462677FBF805E7E6857F@MX09A.corp.emc.com>
	<8449503C-66B3-4CDC-89BF-5B52E6D29579@whamcloud.com>
	<5F3A45681A0F5944B3194CF8C8FB905B66FA4DD4F9@MX17A.corp.emc.com>
	<4F19A01B.4070405@whamcloud.com>
Message-ID: <F19688880B763E40B28B2B462677FBF805E7E68AA7@MX09A.corp.emc.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Fan Yong,

Sorry for the late reply. I got your email earlier but didn't have chance to read the document due to very limited internet access.

Thank you very much for taking detailed look at the document and giving so many valuable comments.

About adding new inode bitlock, I must admit that I missed hardlink case. Although the lock mode can be changed to be the same as LOOKUP lock, I agree that inode bitlock cannot sufficiently protect every name/dentry separately for hardlinked files. And I agree, as you suggested in the document, adding a name entry based lock can solve it.

IIUC, to add a name entry based lock, both client and server should be modified, and LDLM need to be changed to manage the new lock information. Like new inode bitlock, the name entry based lock will as well introduce interoperability issues as a result of on wire protocol change. And in DNE environment as Andreas explained, the original plan is to get LOOKUP on both master MDT and remote MDT. If we introduce name entry based lock, DNE case may need some change as well.

I will take a closer look at the approach. In the meanwhile, could you please confirm if it is the right way to go? The benefit of above complexity seems to be better distributed dentry locking under dcache framework.

What do others think? Andreas?

Thanks and Best Regards,
Tao

> -----Original Message-----
> From: Fan Yong [mailto:yong.fan at whamcloud.com]
> Sent: Saturday, January 21, 2012 1:11 AM
> To: Peng, Tao; bergwolf at gmail.com
> Cc: Tang, Haiying; adilger at whamcloud.com; faibish, sorin; Liu, Xuezhao; laisiyao at whamcloud.com;
> green at whamcloud.com; eeb at whamcloud.com; Bryon Neitzel
> Subject: Re: Lustre dcache clean up and distributed locking
> 
> Hi Tao,
> 
> Excellent work. I just added some comments inside your document. Please check.
> 
> 
> Best Regards,
> Fan Yong
> Whamcloud, Inc.
> 
> On 1/20/12 9:34 AM, haiying.tang at emc.com wrote:
> > Hi Andreas,
> >
> > Tao is on vacation now. It might be difficult for him to check emails due to limited internet access
> at hometown.
> > For urgent issue, you folks could send email to his gmail account bergwolf at gmail.com.
> >
> > Thanks,
> > Haiying
> >
> > -----Original Message-----
> > From: Andreas Dilger [mailto:adilger at whamcloud.com]
> > Sent: 2012?1?20? 1:39
> > To: Peng, Tao
> > Cc: faibish, sorin; Tang, Haiying; Liu, Xuezhao;
> > laisiyao at whamcloud.com; yong.fan at whamcloud.com; green at whamcloud.com;
> > eeb at whamcloud.com
> > Subject: Re: Lustre dcache clean up and distributed locking
> >
> > On 2012-01-17, at 3:21 AM, <tao.peng@emc.com> <tao.peng@emc.com> wrote:
> >> Thanks Siyao and Oleg for answering my dcache revalidation question on lustre mailing list. I
> updated the design to reflect it.
> >>
> >> Please see attachment.
> > Tao,
> > Fan Yong is also taking a more detailed look at your document and will
> > hopefully have a chance to reply before the New Year holidays.
> >
> > Also, we are just working on landing the patches to add support for
> > Linux
> > 2.6.38 for the Lustre client.  One of the patches relates to the
> > lockless dcache changes that were introduced in that kernel.  If you
> > are interested to review this patch, and become more familiar with the
> > Lustre development process, you should visit http://review.whamcloud.com/1865 for the patch.
> >
> > You need to create an account in Gerrit using OpenID (Google, mostly),
> > and an account in our bug tracking system (http://jira.whamcloud.com)
> > if you haven't already.
> >
> >>> -----Original Message-----
> >>> From: Andreas Dilger [mailto:adilger at whamcloud.com]
> >>> Sent: Tuesday, January 17, 2012 4:16 PM
> >>> To: Peng, Tao
> >>> Cc: faibish, sorin; Tang, Haiying; Liu, Xuezhao; Lai Siyao; Fan
> >>> Yong; Oleg Drokin; Eric Barton
> >>> Subject: Re: Lustre dcache clean up and distributed locking
> >>>
> >>> On 2012-01-16, at 9:25 PM, <tao.peng@emc.com> wrote:
> >>>> I finally started to work on Lustre dcache cleanup and locking.
> >>>> After reading Lustre, ocfs2 and VFS
> >>> dcache related code, I came to a design for cleaning up Lustre
> >>> dcache code and doing distributed locking under dcache. For
> >>> distributed locking, the main idea is to add a new inode bitlock
> >>> DENTRY lock to just protect valid dentry, instead of letting LOOKUP
> >>> lock handle multiple purpose, which makes client unable to know
> >>> whether file is deleted or not when server cancels LOOKUP lock. Instead, client holds PR mode
> DENTRY lock on all valid denties and when server cancels it, client knows the file is deleted.
> >>>> For details, please see the attachments (I attached both word and
> >>>> pdf versions as I am not sure if
> >>> which is more convenient for you:). And please help to review and comment. Thank you!
> >>>
> >>> Hi Tao,
> >>> I'm passing this on to the engineers that are most familiar with the
> >>> DLM and client dcache code in Lustre.  After a quick first read
> >>> through your document, your investigation of the client code is very
> >>> insightful and looks like it will be able to remove some of the significant complexity that has
> grown over time in the llite code.
> >>>
> >>> Cheers, Andreas
> >>> --
> >>> Andreas Dilger                       Whamcloud, Inc.
> >>> Principal Engineer                   http://www.whamcloud.com/
> >>>
> >>>
> >> <dcache_distributed_locking-v2.docx>
> >
> > Cheers, Andreas
> > --
> > Andreas Dilger                       Whamcloud, Inc.
> > Principal Engineer                   http://www.whamcloud.com/
> >
> >
> >
> >
> >
