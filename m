From: Andreas Dilger <adilger@whamcloud.com>
Date: Fri, 10 Feb 2012 13:37:25 -0700
Subject: [Lustre-devel] Lustre dcache clean up and distributed locking
In-Reply-To: <F19688880B763E40B28B2B462677FBF805E803B502@MX09A.corp.emc.com>
References: <F19688880B763E40B28B2B462677FBF805E7E684CD@MX09A.corp.emc.com>
	<AC57B2B9-5559-4713-905D-7AC9BAE3B1DB@whamcloud.com>
	<F19688880B763E40B28B2B462677FBF805E7E6857F@MX09A.corp.emc.com>
	<8449503C-66B3-4CDC-89BF-5B52E6D29579@whamcloud.com>
	<5F3A45681A0F5944B3194CF8C8FB905B66FA4DD4F9@MX17A.corp.emc.com>
	<4F19A01B.4070405@whamcloud.com>
	<F19688880B763E40B28B2B462677FBF805E7E68AA7@MX09A.corp.emc.com>
	<AEB2D859-5F0D-4D32-9719-DDD993D6921A@whamcloud.com>
	<4F27D846.6010504@whamcloud.com>
	<F19688880B763E40B28B2B462677FBF805E803AF01@MX09A.corp.emc.com>
	<4F2C08A3.4060206@whamcloud.com>
	<F19688880B763E40B28B2B462677FBF805E803B502@MX09A.corp.emc.com>
Message-ID: <FEF73DB7-4C26-4BFA-BD27-6F48A9940BB4@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2012-02-09, at 12:15 AM, <tao.peng@emc.com> <tao.peng@emc.com> wrote:
> Fan Yong <yong.fan@whamcloud.com> wrote:
>> We has another way to remove Lustre special dentry flags
>> "DCACHE_LUSTRE_INVALID". To indicate the dentry in dcache without LOOKUP
>> lock protected but not unhashed yet, we can add new flags in
>> "ll_dentry_data" (pointed by "dentry::d_fsdata"). Since it is Lustre
>> private date, no need to worry about whether the new flags will conflict
>> with any other VFS standard "dentry::d_flags" or not, and maybe save
>> some effort to implement the complex DENTRY lock in your original design.
> 
> Hi Fan Yong,
> 
> Thanks for your great suggestion. I updated the design doc with following changes, please help to review. Thank you!
> 
> Changelog:
> 1. Macro cleanups are removed. I prefer to do it separately while cleaning up other obsolete macros.
> 2. Remove DENTRY LDLM lock proposal. Because DCACHE_LUSTRE_INVALID flag can be hidden from generic VFS layer, it is no longer necessary to introduce such complex change.
> 3. Add a section to describe how to add LLD_LUSTRE_INVALID flag to ll_dentry_data structure to replace existing DCACHE_LUSTRE_INVALID flag.

Hi Tao,
these cleanups look quite reasonable now.  Will you be working on making
these changes for Lustre?  The feature freeze for the Lustre 2.2 release
was Jan 7, so any non-bugfix changes will need to land for Lustre 2.3.

However, that doesn't prevent you from working on these patches and sending
them to Gerrit for inspection, testing, and getting them ready for landing.
You should base your patch on top of the most recent dcache patch in

http://review.whamcloud.com/1865

If you haven't looked already, please read the following wiki pages:

http://wiki.whamcloud.com/display/PUB/Submitting+Changes
http://wiki.whamcloud.com/display/PUB/Using+Gerrit

for details on how to submit patches to Gerrit for review/testing/landing.



Cheers, Andreas
--
Andreas Dilger                       Whamcloud, Inc.
Principal Lustre Engineer            http://www.whamcloud.com/
