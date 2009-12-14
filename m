From: Brian Reitz <Brian.Reitz@Sun.COM>
Date: Mon, 14 Dec 2009 14:23:32 -0600
Subject: [Lustre-devel] Lustre transition to Git has been completed.
Message-ID: <4AAC4879-9522-4CCF-AE96-EA95DE84947E@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


The Lustre transition to Git has been completed.  You can find more information about Lustre and Git in the email below.

Included as an attachment to this email is a torrent from which you can download a tarball of the lustre git repository.  To ease initial demands on the repository, please use the .torrent.

Brian





> What is happening?
> 
> The Lustre source repository is moving from CVS, where it has lived for the last 7+ years to Git.  This will simplify ongoing development of Lustre in a number of ways, including tracking of changes and history, improved merging of development branches into releases, and offline development.
> 
> Unfortunately, due to the lengthy use and abuse of CVS to manage the Lustre code, it is not possible to do a straight import of the entire CVS repository into Git using any existing tools.  Rather than simply importing the current state of the code into Git and lose all of the history, we've worked to import the major development branches along with their full history into a single Git repository to maximize its usefulness.
> 
> When is this happening?
> 
> Monday December 14 2009 is the target date for switching all Lustre development from CVS to Git. 
> 
> All CVS Repositories will transition to read-only state on Friday December 11, 2009 at 9:00 am CST. The CVS repository will remain in this read-only state for the duration of the conversion process.  Please make your plans accordingly.
> 
> The conversion to Git will be done over the weekend (12/11/2009 - 12/13/2009).  The resulting Git repository will be available on Monday December 14 2009 at 12:00 PM CST.  The CVS tree will remain in a read-only state from this point on.  All subsequent code changes must be done via Git.
> 
> Instructions on using Git with the Lustre code base can be found here: 
> 
> http://wiki.lustre.org/index.php/Accessing_Lustre_Code
> http://wiki.lustre.org/index.php/Applying_Lustre_Patches_to_a_Kernel
> http://wiki.lustre.org/index.php/Submitting_Patches
> 
> What is supported?
> 
> Following Branches are migrated to GIT
> 
> 	b1_6
>  	b1_8
>  	b_release_1_6_7
>  	b_release_1_8_0
>  	b_release_1_8_1
>  	master aka HEAD represents 2.0 work
> 
> A limited number of tags are also supported in the git repository.  Only v* tags post 1.6.7 are supported.  
> 
> What is not supported?
> 
> 	b1_4 branch will not be migrated and will be maintained under cvs.
> 
> Developer Migration Notes
> 
> To make your migration to git easier you should update any of your development CVS branches from the base, and land outstanding work in those development branches before Friday December 11, 2009.  Working directories that contain uncommitted changes should also be updated, but can be done after the migration while the CVS repository is in a read-only mode.
>  
> Tags will be placed in the CVS repository to mark the point were the conversion was done:
> 
>         B1_6_GIT_BASE
>         B1_8_GIT_BASE
>         B_RELEASE_1_6_7_GIT_BASE
>         B_RELEASE_1_8_0_GIT_BASE
>         B_RELEASE_1_8_1_GIT_BASE
>         B2_0_GIT_BASE
> 
> In addition tags will also be in place in the Git repository marking the spot of the conversion:
> 
>         GIT_EPOCH_B1_6
>         GIT_EPOCH_B1_8
>         GIT_EPOCH_B_RELEASE_1_6_7
>         GIT_EPOCH_B_RELEASE_1_8_0
>         GIT_EPOCH_B_RELEASE_1_8_1
>         GIT_EPOCH_MASTER
> 
> Support
> 
> lustre-devel at sun.com
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20091214/8e16409c/attachment.htm>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: Lustre-prime-2009-12-14.tar.gz.torrent
Type: application/x-bittorrent
Size: 19401 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20091214/8e16409c/attachment.torrent>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20091214/8e16409c/attachment-0001.htm>
